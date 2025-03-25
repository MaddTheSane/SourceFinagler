/*
 * HLLib
 * Copyright (C) 2006-2010 Ryan Gregg

 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later
 * version.
 */

#ifndef NCFFILE_H
#define NCFFILE_H

#include <HL/stdafx.h>
#include <HL/Package.h>

namespace HLLib
{
	class HLLIB_API CNCFFile : public CPackage
	{
	private:
		#pragma pack(1)

		struct NCFHeader
		{
			//! Always `0x00000001`
			hlUInt uiDummy0;
			//! Always `0x00000002`
			hlUInt uiMajorVersion;
			//! NCF version number.
			hlUInt uiMinorVersion;
			hlUInt uiCacheID;
			hlUInt uiLastVersionPlayed;
			hlUInt uiDummy3;
			hlUInt uiDummy4;
			//! Total size of NCF file in bytes.
			hlUInt uiFileSize;
			//! Size of each data block in bytes.
			hlUInt uiBlockSize;
			//! Number of data blocks.
			hlUInt uiBlockCount;
			
			hlUInt uiDummy5;
		};

		struct NCFDirectoryHeader
		{
			//! Always `0x00000004`
			hlUInt uiDummy0;
			//! Cache ID.
			hlUInt uiCacheID;
			//! NCF file version.
			hlUInt uiLastVersionPlayed;
			//! Number of items in the directory.
			hlUInt uiItemCount;
			//! Number of files in the directory.
			hlUInt uiFileCount;
			//! Always `0x00008000`.  Data per checksum?
			hlUInt uiChecksumDataLength;
			//! Size of `lpNCFDirectoryEntries` & `lpNCFDirectoryNames` & `lpNCFDirectoryInfo1Entries` & `lpNCFDirectoryInfo2Entries` & `lpNCFDirectoryCopyEntries` & `lpNCFDirectoryLocalEntries` in bytes.
			hlUInt uiDirectorySize;
			//! Size of the directory names in bytes.
			hlUInt uiNameSize;
			//! Number of Info1 entires.
			hlUInt uiInfo1Count;
			//! Number of files to copy.
			hlUInt uiCopyCount;
			//! Number of files to keep local.
			hlUInt uiLocalCount;
			
			hlUInt uiDummy1;
			hlUInt uiDummy2;
			//! Header checksum.
			hlUInt uiChecksum;
		};

		struct NCFDirectoryEntry
		{
			//! Offset to the directory item name from the end of the directory items.
			hlUInt uiNameOffset;
			//! Size of the item.  (If file, file size.  If folder, num items.)
			hlUInt uiItemSize;
			//! Checksome index. (`0xFFFFFFFF` == None).
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

		struct NCFDirectoryInfo1Entry
		{
			hlUInt uiDummy0;
		};

		struct NCFDirectoryInfo2Entry
		{
			hlUInt uiDummy0;
		};

		struct NCFDirectoryCopyEntry
		{
			//! Index of the directory item.
			hlUInt uiDirectoryIndex;
		};

		struct NCFDirectoryLocalEntry
		{
			//! Index of the directory item.
			hlUInt uiDirectoryIndex;
		};

		struct NCFUnknownHeader
		{
			//! Always 0x00000001
			hlUInt uiDummy0;
			//! Always 0x00000000
			hlUInt uiDummy1;
		};

		struct NCFUnknownEntry
		{
			hlUInt uiDummy0;
		};

		struct NCFChecksumHeader
		{
			//! Always 0x00000001
			hlUInt uiDummy0;
			//! Size of `LPNCFCHECKSUMHEADER` & `LPNCFCHECKSUMMAPHEADER` & in bytes.
			hlUInt uiChecksumSize;
		};

		struct NCFChecksumMapHeader
		{
			//! Always 0x14893721
			hlUInt uiDummy0;
			//! Always `0x00000001`
			hlUInt uiDummy1;
			//! Number of items.
			hlUInt uiItemCount;
			//! Number of checksums.
			hlUInt uiChecksumCount;
		};

		struct NCFChecksumMapEntry
		{
			//! Number of checksums.
			hlUInt uiChecksumCount;
			//! Index of first checksum.
			hlUInt uiFirstChecksumIndex;
		};

		struct NCFChecksumEntry
		{
			//! Checksum.
			hlULong uiChecksum;
		};

		#pragma pack()

	private:
		static const char *lpAttributeNames[];
		static const char *lpItemAttributeNames[];

		hlChar *lpRootPath;

		Mapping::CView *pHeaderView;

		NCFHeader *pHeader;

		NCFDirectoryHeader *pDirectoryHeader;
		NCFDirectoryEntry *lpDirectoryEntries;
		hlChar *lpDirectoryNames;
		NCFDirectoryInfo1Entry *lpDirectoryInfo1Entries;
		NCFDirectoryInfo2Entry *lpDirectoryInfo2Entries;
		NCFDirectoryCopyEntry *lpDirectoryCopyEntries;
		NCFDirectoryLocalEntry *lpDirectoryLocalEntries;

		NCFUnknownHeader *pUnknownHeader;
		NCFUnknownEntry *lpUnknownEntries;

		NCFChecksumHeader *pChecksumHeader;
		NCFChecksumMapHeader *pChecksumMapHeader;
		NCFChecksumMapEntry *lpChecksumMapEntries;
		NCFChecksumEntry *lpChecksumEntries;

	public:
		CNCFFile();
		virtual ~CNCFFile();

		virtual HLPackageType GetType() const;
		virtual const hlChar *GetExtension() const;
		virtual const hlChar *GetDescription() const;

		const hlChar *GetRootPath() const;
		hlVoid SetRootPath(const hlChar *lpRootPath);

	protected:
		virtual hlBool MapDataStructures();
		virtual hlVoid UnmapDataStructures();

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

		hlVoid GetPath(const CDirectoryFile *pFile, hlChar *lpPath, hlUInt uiPathSize) const;
	};
}

#endif
