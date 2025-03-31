/*
 * VTFLib
 * Copyright (C) 2005-2010 Neil Jedrzejewski & Ryan Gregg

 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later
 * version.
 */

#pragma once
#ifndef PROC_H
#define PROC_H

#include <VTF/stdafx.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum tagVLProc
{
	PROC_READ_CLOSE = 0,
	PROC_READ_OPEN,
	PROC_READ_READ,
	PROC_READ_SEEK,
	PROC_READ_TELL,
	PROC_READ_SIZE,
	PROC_WRITE_CLOSE,
	PROC_WRITE_OPEN,
	PROC_WRITE_WRITE,
	PROC_WRITE_SEEK,
	PROC_WRITE_SIZE,
	PROC_WRITE_TELL,
	PROC_COUNT
} VLProc;

//typedef enum tagVLSeekMode
// {
//	SEEK_MODE_BEGIN = 0,
//	SEEK_MODE_CURRENT,
//	SEEK_MODE_END
//} VLSeekMode;

typedef vlVoid (*PReadCloseProc)(vlVoid *);
typedef vlBool (*PReadOpenProc) (vlVoid *);
typedef vlUInt (*PReadReadProc) (vlVoid *, vlUInt, vlVoid *);
typedef vlUInt (*PReadSeekProc) (vlLong, VLSeekMode, vlVoid *);
typedef vlUInt (*PReadSizeProc) (vlVoid *);
typedef vlUInt (*PReadTellProc) (vlVoid *);

typedef vlVoid (*PWriteCloseProc)(vlVoid *);
typedef vlBool (*PWriteOpenProc) (vlVoid *);
typedef vlUInt (*PWriteWriteProc)(vlVoid *, vlUInt, vlVoid *);
typedef vlUInt (*PWriteSeekProc) (vlLong, VLSeekMode, vlVoid *);
typedef vlUInt (*PWriteSizeProc) (vlVoid *);
typedef vlUInt (*PWriteTellProc) (vlVoid *);

#ifdef __cplusplus
}

namespace VTFLib
{
	VTFLIB_API extern PReadCloseProc pReadCloseProc;
	VTFLIB_API extern PReadOpenProc pReadOpenProc;
	VTFLIB_API extern PReadReadProc pReadReadProc;
	VTFLIB_API extern PReadSeekProc pReadSeekProc;
	VTFLIB_API extern PReadSizeProc pReadSizeProc;
	VTFLIB_API extern PReadTellProc pReadTellProc;

	VTFLIB_API extern PWriteCloseProc pWriteCloseProc;
	VTFLIB_API extern PWriteOpenProc pWriteOpenProc;
	VTFLIB_API extern PWriteWriteProc pWriteWriteProc;
	VTFLIB_API extern PWriteSeekProc pWriteSeekProc;
	VTFLIB_API extern PWriteSizeProc pWriteSizeProc;
	VTFLIB_API extern PWriteTellProc pWriteTellProc;
}

extern "C" {
#endif

VTFLIB_API vlVoid vlSetProc(VLProc Proc, vlVoid *pProc);
VTFLIB_API vlVoid *vlGetProc(VLProc Proc);

#ifdef __cplusplus
}
#endif

#endif
