// This code is in the public domain -- Ignacio Casta�o <castano@gmail.com>

#pragma once
#ifndef NV_CORE_HASHMAP_H
#define NV_CORE_HASHMAP_H

/*
HashMap based on Thatcher Ulrich <tu@tulrich.com> container, donated to the Public Domain.

I'd like to do something to reduce the amount of code generated with this template. The type of 
U is largely irrelevant to the generated code, except for calls to constructors and destructors,
but the combination of all T and U pairs, generate a large amounts of code.

HashMap is not used in NVTT, so it could be removed from the repository.
*/


#include <NVCore/CoreDefines.h>
#include <NVCore/Memory.h>
#include <NVCore/Debug.h>
#include <NVCore/Stream.h>
#include <NVCore/Utils.h> // hash
#include <NVCore/ForEach.h> // foreach/pseudoindex

#include <new>		// for placement new


namespace nv 
{
    /** Thatcher Ulrich's hash table.
    *
    * Hash table, linear probing, internal chaining.  One
    * interesting/nice thing about this implementation is that the table
    * itself is a flat chunk of memory containing no pointers, only
    * relative indices.  If the key and value types of the hash contain
    * no pointers, then the hash can be serialized using raw IO.  Could
    * come in handy.
    *
    * Never shrinks, unless you explicitly clear() it.  Expands on
    * demand, though.  For best results, if you know roughly how big your
    * table will be, default it to that size when you create it.
    */
    template<typename T, typename U, typename H = Hash<T>, typename E = Equal<T> >
    class NVCORE_CLASS HashMap
    {
        NV_FORBID_COPY(HashMap)
    public:

        /// Default ctor.
        HashMap() : entry_count(0), size_mask(-1), table(NULL) { }

        /// Ctor with size hint.
        explicit HashMap(int size_hint) : entry_count(0), size_mask(-1), table(NULL) { setCapacity(size_hint); }

        /// Dtor.
        ~HashMap() { clear(); }


        /// Set a new or existing value under the key, to the value.
        void set(const T& key, const U& value)
        {
            int	index = findIndex(key);
            if (index >= 0)
            {
                entry(index).value = value;
                return;
            }

            // Entry under key doesn't exist.
            add(key, value);
        }


        /// Add a new value to the hash table, under the specified key.
        void add(const T& key, const U& value)
        {
            nvCheck(findIndex(key) == -1);

            checkExpand();
            nvCheck(table != NULL);
            entry_count++;

            const uint hash_value = compute_hash(key);
            const int index = hash_value & size_mask;

            Entry * natural_entry = &(entry(index));

            if (natural_entry->isEmpty())
            {
                // Put the new entry in.
                new (natural_entry) Entry(key, value, -1, hash_value);
            } 
            else if (natural_entry->isTombstone()) {
                // Put the new entry in, without disturbing the rest of the chain.
                int next_in_chain = natural_entry->next_in_chain;
                new (natural_entry) Entry(key, value, next_in_chain, hash_value);
            }
            else
            {
                // Find a blank spot.
                int	blank_index = index;
                for (int search_count = 0; ; search_count++)
                {
                    blank_index = (blank_index + 1) & size_mask;
                    if (entry(blank_index).isEmpty()) break;	// found it
                    if (entry(blank_index).isTombstone()) {
                        blank_index = removeTombstone(blank_index);
                        break;
                    }
                    nvCheck(search_count < this->size_mask);
                }
                Entry * blank_entry = &entry(blank_index);

                if (int(natural_entry->hash_value & size_mask) == index)
                {
                    // Collision.  Link into this chain.

                    // Move existing list head.
                    new (blank_entry) Entry(*natural_entry);	// placement new, copy ctor

                    // Put the new info in the natural entry.
                    natural_entry->key = key;
                    natural_entry->value = value;
                    natural_entry->next_in_chain = blank_index;
                    natural_entry->hash_value = hash_value;
                }
                else
                {
                    // Existing entry does not naturally
                    // belong in this slot.  Existing
                    // entry must be moved.

                    // Find natural location of collided element (i.e. root of chain)
                    int	collided_index = natural_entry->hash_value & size_mask;
                    for (int search_count = 0; ; search_count++)
                    {
                        Entry * e = &entry(collided_index);
                        if (e->next_in_chain == index)
                        {
                            // Here's where we need to splice.
                            new (blank_entry) Entry(*natural_entry);
                            e->next_in_chain = blank_index;
                            break;
                        }
                        collided_index = e->next_in_chain;
                        nvCheck(collided_index >= 0 && collided_index <= size_mask);
                        nvCheck(search_count <= size_mask);
                    }

                    // Put the new data in the natural entry.
                    natural_entry->key = key;
                    natural_entry->value = value;
                    natural_entry->hash_value = hash_value;
                    natural_entry->next_in_chain = -1;
                }
            }
        }


        /// Remove the first value under the specified key.
        bool remove(const T& key)
        {
            if (table == NULL)
            {
                return false;
            }

            int	index = findIndex(key);
            if (index < 0)
            {
                return false;
            }

            Entry * pos = &entry(index);

            int natural_index = (int) (pos->hash_value & size_mask);

            if (index != natural_index) {
                // We're not the head of our chain, so we can
                // be spliced out of it.

                // Iterate up the chain, and splice out when
                // we get to m_index.
                Entry* e = &entry(natural_index);
                while (e->next_in_chain != index) {
                    assert(e->isEndOfChain() == false);
                    e = &entry(e->next_in_chain);
                }

                if (e->isTombstone() && pos->isEndOfChain()) {
                    // Tombstone has nothing else to point
                    // to, so mark it empty.
                    e->next_in_chain = -2;
                } else {
                    e->next_in_chain = pos->next_in_chain;
                }

                pos->clear();
            }
            else if (pos->isEndOfChain() == false) {
                // We're the head of our chain, and there are
                // additional elements.
                //
                // We need to put a tombstone here.
                //
                // We can't clear the element, because the
                // rest of the elements in the chain must be
                // linked to this position.
                //
                // We can't move any of the succeeding
                // elements in the chain (i.e. to fill this
                // entry), because we don't want to invalidate
                // any other existing iterators.
                pos->makeTombstone();
            } else {
                // We're the head of the chain, but we're the
                // only member of the chain.
                pos->clear();
            }

            entry_count--;

            return true;
        }


        /// Remove all entries from the hash table.
        void clear()
        {
            if (table != NULL)
            {
                // Delete the entries.
                for (int i = 0, n = size_mask; i <= n; i++)
                {
                    Entry * e = &entry(i);
                    if (e->isEmpty() == false && e->isTombstone() == false)
                    {
                        e->clear();
                    }
                }
                free(table);
                table = NULL;
                entry_count = 0;
                size_mask = -1;
            }
        }


        /// Returns true if the hash is empty.
        bool isEmpty() const
        {
            return table == NULL || entry_count == 0;
        }


        /** Retrieve the value under the given key.
        *
        * If there's no value under the key, then return false and leave
        * *value alone.
        *
        * If there is a value, return true, and set *value to the entry's
        * value.
        *
        * If value == NULL, return true or false according to the
        * presence of the key, but don't touch *value.
        */
        bool get(const T& key, U* value = NULL) const
        {
            int	index = findIndex(key);
            if (index >= 0)
            {
                if (value) {
                    *value = entry(index).value;	// take care with side-effects!
                }
                return true;
            }
            return false;
        }

        /// Determine if the given key is contained in the hash.
        bool contains(const T & key) const
        {
            return get(key);
        }

        /// Number of entries in the hash.
        int	size() const
        {
            return entry_count;
        }

        /// Number of entries in the hash.
        int	count() const
        {
            return size();
        }


        /**
        * Resize the hash table to fit one more entry.  Often this
        * doesn't involve any action.
        */
        void checkExpand()
        {
            if (table == NULL) {
                // Initial creation of table.  Make a minimum-sized table.
                setRawCapacity(16);
            } 
            else if (entry_count * 3 > (size_mask + 1) * 2) {
                // Table is more than 2/3rds full.  Expand.
                setRawCapacity(entry_count * 2);
            }
        }


        /// Hint the bucket count to >= n.
        void resize(int n)
        {
            // Not really sure what this means in relation to
            // STLport's hash_map... they say they "increase the
            // bucket count to at least n" -- but does that mean
            // their real capacity after resize(n) is more like
            // n*2 (since they do linked-list chaining within
            // buckets?).
            setCapacity(n);
        }

        /**
        * Size the hash so that it can comfortably contain the given
        * number of elements.  If the hash already contains more
        * elements than new_size, then this may be a no-op.
        */
        void setCapacity(int new_size)
        {
            int	new_raw_size = (new_size * 3) / 2;
            if (new_raw_size < size()) { return; }

            setRawCapacity(new_raw_size);
        }

        /// Behaves much like std::pair.
        struct Entry
        {
            int	next_in_chain;	// internal chaining for collisions
            uint hash_value;	// avoids recomputing.  Worthwhile?
            T key;
            U value;

            Entry() : next_in_chain(-2) {}
            Entry(const Entry& e)
                : next_in_chain(e.next_in_chain), hash_value(e.hash_value), key(e.key), value(e.value)
            {
            }
            Entry(const T& k, const U& v, int next, int hash)
                : next_in_chain(next), hash_value(hash), key(k), value(v)
            {
            }
            bool isEmpty() const { return next_in_chain == -2; }
            bool isEndOfChain() const { return next_in_chain == -1; }
            bool isTombstone() const { return hash_value == TOMBSTONE_HASH; }

            void clear()
            {
                key.~T();	// placement delete
                value.~U();	// placement delete
                next_in_chain = -2;
                hash_value = ~TOMBSTONE_HASH;
            }

            void makeTombstone()
            {
                key.~T();
                value.~U();
                hash_value = TOMBSTONE_HASH;
            }
        };


        // HashMap enumerator.
        typedef int PseudoIndex;
        PseudoIndex start() const { PseudoIndex i = 0; findNext(i); return i; }
        bool isDone(const PseudoIndex & i) const { nvDebugCheck(i <= size_mask+1); return i == size_mask+1; };
        void advance(PseudoIndex & i) const { nvDebugCheck(i <= size_mask+1); i++; findNext(i); }

#if NV_CC_GNUC
        Entry & operator[]( const PseudoIndex & i ) {
            Entry & e = entry(i);
            nvDebugCheck(e.isTombstone() == false);
            return e;
        }
        const Entry & operator[]( const PseudoIndex & i ) const {
            const Entry & e = entry(i);
            nvDebugCheck(e.isTombstone() == false);
            return e;
        }
#elif NV_CC_MSVC
        Entry & operator[]( const PseudoIndexWrapper & i ) {
            Entry & e = entry(i(this));
            nvDebugCheck(e.isTombstone() == false);
            return e;
        }
        const Entry & operator[]( const PseudoIndexWrapper & i ) const {
            const Entry & e = entry(i(this));
            nvDebugCheck(e.isTombstone() == false);
            return e;
        }
#endif

        // These two functions are not tested:

        // By default we serialize the key-value pairs compactly.
        friend Stream & operator<< (Stream & s, HashMap<T, U, H, E> & map)
        {
            int entry_count = map.entry_count;
            s << entry_count;

            if (s.isLoading()) {
                map.clear();
                if(entry_count == 0) {
                    return s;
                }
                map.entry_count = entry_count;
                map.size_mask = nextPowerOfTwo(entry_count) - 1;
                map.table = malloc<Entry>(map.size_mask + 1);
                
                for (int i = 0; i <= map.size_mask; i++) {
                    map.table[i].next_in_chain = -2;	// mark empty
                }

                T key;
                U value;
                for (int i = 0; i < entry_count; i++) {
                    s << key << value;
                    map.add(key, value);
                }
            }
            else {
                for(int i = start(); !isDone(i); advance(i)) {
                //foreach(i, map) {
                    s << map[i].key << map[i].value;
                }
            }

            return s;
        }

        // This requires more storage, but saves us from rehashing the elements.
        friend Stream & rawSerialize(Stream & s, HashMap<T, U, H, E> & map)
        {
            if (s.isLoading()) {
                map.clear();
            }

            s << map.size_mask;

            if (map.size_mask != -1) {
                s << map.entry_count;

                if (s.isLoading()) {
                    map.table = new Entry[map.size_mask+1];
                }

                for (int i = 0; i <= map.size_mask; i++) {
                    Entry & e = map.table[i];
                    s << e.next_in_chain << e.hash_value;
                    s << e.key;
                    s << e.value;
                }
            }

            return s;
        }

        /// Swap the members of this vector and the given vector.
        friend void swap(HashMap<T, U, H, E> & a, HashMap<T, U, H, E> & b)
        {
            swap(a.entry_count, b.entry_count);
            swap(a.size_mask, b.size_mask);
            swap(a.table, b.table);
        }

    private:
        static const uint TOMBSTONE_HASH = (uint) -1;

        uint compute_hash(const T& key) const
        {
            H hash;
            uint hash_value = hash(key);
            if (hash_value == TOMBSTONE_HASH) {
                hash_value ^= 0x8000;
            }
            return hash_value;
        }

        // Find the index of the matching entry. If no match, then return -1.
        int	findIndex(const T& key) const
        {
            if (table == NULL) return -1;

            E equal;

            uint hash_value = compute_hash(key);
            int	index = hash_value & size_mask;

            const Entry * e = &entry(index);
            if (e->isEmpty()) return -1;
            if (e->isTombstone() == false && int(e->hash_value & size_mask) != index) {
                // occupied by a collider
                return -1;
            }

            for (;;)
            {
                nvCheck(e->isTombstone() || (e->hash_value & size_mask) == (hash_value & size_mask));

                if (e->hash_value == hash_value && equal(e->key, key))
                {
                    // Found it.
                    return index;
                }
                nvDebugCheck(e->isTombstone() || !equal(e->key, key));   // keys are equal, but hash differs!

                // Keep looking through the chain.
                index = e->next_in_chain;
                if (index == -1) break;	// end of chain

                nvCheck(index >= 0 && index <= size_mask);
                e = &entry(index);

                nvCheck(e->isEmpty() == false || e->isTombstone());
            }
            return -1;
        }

        // Return the index of the newly cleared element.
        int removeTombstone(int index) {
	        Entry* e = &entry(index);
	        nvCheck(e->isTombstone());
	        nvCheck(!e->isEndOfChain());

	        // Move the next element of the chain into the
	        // tombstone slot, and return the vacated element.
	        int new_blank_index = e->next_in_chain;
	        Entry* new_blank = &entry(new_blank_index);
	        new (e) Entry(*new_blank);
	        new_blank->clear();
	        return new_blank_index;
        }

        // Helpers.
        Entry & entry(int index)
        {
            nvDebugCheck(table != NULL);
            nvDebugCheck(index >= 0 && index <= size_mask);
            return table[index];
        }
        const Entry & entry(int index) const
        {
            nvDebugCheck(table != NULL);
            nvDebugCheck(index >= 0 && index <= size_mask);
            return table[index];
        }


        /**
        * Resize the hash table to the given size (Rehash the
        * contents of the current table).  The arg is the number of
        * hash table entries, not the number of elements we should
        * actually contain (which will be less than this).
        */
        void setRawCapacity(int new_size)
        {
            if (new_size <= 0) {
                // Special case.
                clear();
                return;
            }

            // Force new_size to be a power of two.
            new_size = nextPowerOfTwo(new_size);

            HashMap<T, U, H, E> new_hash;
            new_hash.table = malloc<Entry>(new_size);
            nvDebugCheck(new_hash.table != NULL);

            new_hash.entry_count = 0;
            new_hash.size_mask = new_size - 1;
            for (int i = 0; i < new_size; i++)
            {
                new_hash.entry(i).next_in_chain = -2;	// mark empty
            }

            // Copy stuff to new_hash
            if (table != NULL)
            {
                for (int i = 0, n = size_mask; i <= n; i++)
                {
                    Entry * e = &entry(i);
                    if (e->isEmpty() == false && e->isTombstone() == false)
                    {
                        // Insert old entry into new hash.
                        new_hash.add(e->key, e->value);
                        e->clear();	// placement delete of old element
                    }
                }

                // Delete our old data buffer.
                free(table);
            }

            // Steal new_hash's data.
            entry_count = new_hash.entry_count;
            size_mask = new_hash.size_mask;
            table = new_hash.table;
            new_hash.entry_count = 0;
            new_hash.size_mask = -1;
            new_hash.table = NULL;
        }

        // Move the enumerator to the next valid element.
        void findNext(PseudoIndex & i) const {
            while (i <= size_mask) {
                const Entry & e = entry(i);
                if (e.isEmpty() == false && e.isTombstone() == false) {
                    break;
                }
                i++;
            }
        }


        int	entry_count;
        int	size_mask;
        Entry * table;

    };

} // nv namespace

#endif // NV_CORE_HASHMAP_H
