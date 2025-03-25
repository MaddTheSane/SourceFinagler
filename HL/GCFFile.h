/*
 * HLLib
 * Copyright (C) 2006-2010 Ryan Gregg

 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later
 * version.
 */

#ifndef GCFFILE_H
#define GCFFILE_H

#include <HL/stdafx.h>
#include <HL/Package.h>

namespace HLLib
{
	namespace Streams
	{
		class CGCFStream;
	}

	class HLLIB_API CGCFFile : public CPackage
	{
		friend class Streams::CGCFStream;

	private:
		#pragma pack(1)

		struct GCFHeader
		{
			//! Always `0x00000001`
			hlUInt uiDummy0;
			//! Always `0x00000001`
			//! GCF version number.
			hlUInt uiMajorVersion;
			//! GCF version number.
			hlUInt uiMinorVersion;
			
			hlUInt uiCacheID;
			hlUInt uiLastVersionPlayed;
			hlUInt uiDummy1;
			hlUInt uiDummy2;
			//! Total size of GCF file in bytes.
			hlUInt uiFileSize;
			//! Size of each data block in bytes.
			hlUInt uiBlockSize;
			//! Number of data blocks.
			hlUInt uiBlockCount;
			
			hlUInt uiDummy3;
		};

		struct GCFBlockEntryHeader
		{
			//! Number of data blocks.
			hlUInt uiBlockCount;
			//! Number of data blocks that point to data.
			hlUInt uiBlocksUsed;
			
			hlUInt uiDummy0;
			hlUInt uiDummy1;
			hlUInt uiDummy2;
			hlUInt uiDummy3;
			hlUInt uiDummy4;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		struct GCFBlockEntry
		{
			//! Flags for the block entry.  `0x200F0000` == Not used.
			hlUInt uiEntryFlags;
			//! The offset for the data contained in this block entry in the file.
			hlUInt uiFileDataOffset;
			//! The length of the data in this block entry.
			hlUInt uiFileDataSize;
			//! The index to the first data block of this block entry's data.
			hlUInt uiFirstDataBlockIndex;
			//! The next block entry in the series.  (N/A if == BlockCount.)
			hlUInt uiNextBlockEntryIndex;
			//! The previous block entry in the series.  (N/A if == BlockCount.)
			hlUInt uiPreviousBlockEntryIndex;
			//! The index of the block entry in the directory.
			hlUInt uiDirectoryIndex;
		};

		struct GCFFragmentationMapHeader
		{
			//! Number of data blocks.
			hlUInt uiBlockCount;
			//! The index of the first unused fragmentation map entry.
			hlUInt uiFirstUnusedEntry;
			//! The block entry terminator; `0 = 0x0000ffff` or `1 = 0xffffffff`.
			hlUInt uiTerminator;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		struct GCFFragmentationMap
		{
			//! The index of the next data block.
			hlUInt uiNextDataBlockIndex;
		};

		// The below section is part of version 5 but not version 6.

		struct GCFBlockEntryMapHeader
		{
			//! Number of data blocks.
			hlUInt uiBlockCount;
			//! Index of the first block entry.
			hlUInt uiFirstBlockEntryIndex;
			//! Index of the last block entry.
			hlUInt uiLastBlockEntryIndex;
			
			hlUInt uiDummy0;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		struct GCFBlockEntryMap
		{
			//! The previous block entry.  (N/A if == BlockCount.)
			hlUInt uiPreviousBlockEntryIndex;
			//! The next block entry.  (N/A if == BlockCount.)
			hlUInt uiNextBlockEntryIndex;
		};

		// End section.

		struct GCFDirectoryHeader
		{
			//! Always `0x00000004`
			hlUInt uiDummy0;
			//! Cache ID.
			hlUInt uiCacheID;
			//! GCF file version.
			hlUInt uiLastVersionPlayed;
			//! Number of items in the directory.
			hlUInt uiItemCount;
			//! Number of files in the directory.
			hlUInt uiFileCount;
			//! Always `0x00008000`.  Data per checksum?
			hlUInt uiDummy1;
			//! Size of `lpGCFDirectoryEntries` & `lpGCFDirectoryNames` & `lpGCFDirectoryInfo1Entries` & `lpGCFDirectoryInfo2Entries` & `lpGCFDirectoryCopyEntries` & `lpGCFDirectoryLocalEntries` in bytes.
			hlUInt uiDirectorySize;
			//! Size of the directory names in bytes.
			hlUInt uiNameSize;
			//! Number of Info1 entires.
			hlUInt uiInfo1Count;
			//! Number of files to copy.
			hlUInt uiCopyCount;
			//! Number of files to keep local.
			hlUInt uiLocalCount;
			
			hlUInt uiDummy2;
			hlUInt uiDummy3;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		struct GCFDirectoryEntry
		{
			//! Offset to the directory item name from the end of the directory items.
			hlUInt uiNameOffset;
			//! Size of the item.  (If file, file size.  If folder, num items.)
			hlUInt uiItemSize;
			//! Checksum index. (`0xFFFFFFFF` == None).
			hlUInt uiChecksumIndex;
			//! Flags for the directory item.  (`0x00000000` == Folder).
			hlUInt uiDirectoryFlags;
			//! Index of the parent directory item.  (`0xFFFFFFFF` == None).
			hlUInt uiParentIndex;
			//! Index of the next directory item.  (`0x00000000` == None).
			hlUInt uiNextIndex;
			//! Index of the first directory item.  (`0x00000000` == None).
			hlUInt uiFirstIndex;
		};

		struct GCFDirectoryInfo1Entry
		{
			hlUInt uiDummy0;
		};

		struct GCFDirectoryInfo2Entry
		{
			hlUInt uiDummy0;
		};

		struct GCFDirectoryCopyEntry
		{
			//! Index of the directory item.
			hlUInt uiDirectoryIndex;
		};

		struct GCFDirectoryLocalEntry
		{
			//! Index of the directory item.
			hlUInt uiDirectoryIndex;
		};

		// The below header was added in version 4 or version 5.

		struct GCFDirectoryMapHeader
		{
			//! Always `0x00000001`
			hlUInt uiDummy0;
			//! Always `0x00000000`
			hlUInt uiDummy1;
		};

		struct GCFDirectoryMapEntry
		{
			//! Index of the first data block. (N/A if `== BlockCount`.)
			hlUInt uiFirstBlockIndex;
		};

		struct GCFChecksumHeader
		{
			//! Always `0x00000001`
			hlUInt uiDummy0;
			//! Size of `LPGCFCHECKSUMHEADER` & `LPGCFCHECKSUMMAPHEADER` & in bytes.
			hlUInt uiChecksumSize;
		};

		struct GCFChecksumMapHeader
		{
			//! Always `0x14893721`
			hlUInt uiDummy0;
			//! Always `0x00000001`
			hlUInt uiDummy1;
			//! Number of items.
			hlUInt uiItemCount;
			//! Number of checksums.
			hlUInt uiChecksumCount;
		};

		struct GCFChecksumMapEntry
		{
			//! Number of checksums.
			hlUInt uiChecksumCount;
			//! Index of first checksum.
			hlUInt uiFirstChecksumIndex;
		};

		struct GCFChecksumEntry
		{
			//! Checksum.
			hlULong uiChecksum;
		};

		struct GCFDataBlockHeader
		{
			//! GCF file version.  This field is not part of all file versions.
			hlUInt uiLastVersionPlayed;
			//! Number of data blocks.
			hlUInt uiBlockCount;
			//! Size of each data block in bytes.
			hlUInt uiBlockSize;
			//! Offset to first data block.
			hlUInt uiFirstBlockOffset;
			//! Number of data blocks that contain data.
			hlUInt uiBlocksUsed;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		#pragma pack()

	private:
		static const char *lpAttributeNames[];
		static const char *lpItemAttributeNames[];

		Mapping::CView *pHeaderView;

		GCFHeader *pHeader;

		GCFBlockEntryHeader *pBlockEntryHeader;
		GCFBlockEntry *lpBlockEntries;

		GCFFragmentationMapHeader *pFragmentationMapHeader;
		GCFFragmentationMap *lpFragmentationMap;

		// The below section is part of version 5 but not version 6.
		GCFBlockEntryMapHeader *pBlockEntryMapHeader;
		GCFBlockEntryMap *lpBlockEntryMap;

		GCFDirectoryHeader *pDirectoryHeader;
		GCFDirectoryEntry *lpDirectoryEntries;
		hlChar *lpDirectoryNames;
		GCFDirectoryInfo1Entry *lpDirectoryInfo1Entries;
		GCFDirectoryInfo2Entry *lpDirectoryInfo2Entries;
		GCFDirectoryCopyEntry *lpDirectoryCopyEntries;
		GCFDirectoryLocalEntry *lpDirectoryLocalEntries;

		GCFDirectoryMapHeader *pDirectoryMapHeader;
		GCFDirectoryMapEntry *lpDirectoryMapEntries;

		GCFChecksumHeader *pChecksumHeader;
		GCFChecksumMapHeader *pChecksumMapHeader;
		GCFChecksumMapEntry *lpChecksumMapEntries;
		GCFChecksumEntry *lpChecksumEntries;

		GCFDataBlockHeader *pDataBlockHeader;

		CDirectoryItem **lpDirectoryItems;

	public:
		CGCFFile();
		virtual ~CGCFFile();

		virtual HLPackageType GetType() const;
		virtual const hlChar *GetExtension() const;
		virtual const hlChar *GetDescription() const;

	protected:
		virtual hlBool MapDataStructures();
		virtual hlVoid UnmapDataStructures();

		virtual hlBool DefragmentInternal();

		virtual CDirectoryFolder *CreateRoot();

		virtual hlUInt GetAttributeCountInternal() const;
		virtual const hlChar *GetAttributeNameInternal(HLPackageAttribute eAttribute) const;
		virtual hlBool GetAttributeInternal(HLPackageAttribute eAttribute, HLAttribute &Attribute) const;

		virtual hlUInt GetItemAttributeCountInternal() const;
		virtual const hlChar *GetItemAttributeNameInternal(HLPackageAttribute eAttribute) const;
		virtual hlBool GetItemAttributeInternal(const CDirectoryItem *pItem, HLPackageAttribute eAttribute, HLAttribute &Attribute) const;

		virtual hlBool GetFileExtractableInternal(const CDirectoryFile *pFile, hlBool &bExtractable) const;
		virtual hlBool GetFileValidationInternal(const CDirectoryFile *pFile, HLValidation &eValidation) const;
		virtual hlBool GetFileSizeInternal(const CDirectoryFile *pFile, hlUInt &uiSize) const;
		virtual hlBool GetFileSizeOnDiskInternal(const CDirectoryFile *pFile, hlUInt &uiSize) const;

		virtual hlBool CreateStreamInternal(const CDirectoryFile *pFile, Streams::IStream *&pStream) const;

	private:
		hlVoid CreateRoot(CDirectoryFolder *pFolder);

		hlVoid GetItemFragmentation(hlUInt uiDirectoryItemIndex, hlUInt &uiBlocksFragmented, hlUInt &uiBlocksUsed) const;
	};
}

#endif
