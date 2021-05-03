/*
 * HLLib
 * Copyright (C) 2006-2010 Ryan Gregg

 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later
 * version.
 */

#ifndef GCFSTREAM_H
#define GCFSTREAM_H

#include <HL/stdafx.h>
#include <HL/Stream.h>
#include <HL/Mapping.h>
#include <HL/GCFFile.h>

namespace HLLib
{
	namespace Streams
	{
		class HLLIB_API CGCFStream : public IStream
		{
		private:
			hlBool bOpened;
			hlUInt uiMode;

			const CGCFFile &GCFFile;
			hlUInt uiFileID;

			Mapping::CView *pView;
			hlUInt			uiBlockEntryIndex;
			hlULongLong		ullBlockEntryOffset;
			hlUInt			uiDataBlockIndex;
			hlULongLong		ullDataBlockOffset;

			hlULongLong		ullPointer;
			hlULongLong		ullLength;

		public:
			CGCFStream(const CGCFFile &GCFFile, hlUInt uiFileID);
			~CGCFStream();

			virtual HLStreamType GetType() const;

			const CGCFFile &GetPackage() const;
			virtual const hlChar *GetFileName() const;

			virtual hlBool GetOpened() const;
			virtual hlUInt GetMode() const;

			virtual hlBool Open(hlUInt uiMode);
			virtual hlVoid Close();

			virtual hlULongLong GetStreamSize() const;
			virtual hlULongLong GetStreamPointer() const;

			virtual hlULongLong Seek(hlLongLong iOffset, HLSeekMode eSeekMode);

			virtual hlBool Read(hlChar &cChar);
			virtual hlULongLong Read(hlVoid *lpData, hlULongLong ullBytes);

			virtual hlBool Write(hlChar iChar);
			virtual hlULongLong Write(const hlVoid *lpData, hlULongLong ullBytes);

		private:
			hlBool Map(hlULongLong mapUllPointer);
		};
	}
}

#endif
