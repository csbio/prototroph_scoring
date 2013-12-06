@echo off
rem MSVC90COMPP.BAT
rem
rem    Compile and link options for use with MATLAB Compiler.
rem    using the Microsoft Visual C++ compiler 9.0.
rem
rem    $Revision: 1.1.6.1 $  $Date: 2008/02/03 16:00:06 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio 9.0
set VCINSTALLDIR=%VSINSTALLDIR%\VC
rem In this case, LINKERDIR is being used to specify the location of the SDK
set LINKERDIR=C:\Program Files\Microsoft SDKs\Windows\v6.1\
set PATH=%VCINSTALLDIR%\bin\amd64;%LINKERDIR%\bin\x64;%VCINSTALLDIR%\BIN;%VSINSTALLDIR%\Common7\Tools;%VSINSTALLDIR%\Common7\Tools\bin;%MATLAB_BIN%;%PATH%
set INCLUDE=%LINKERDIR%\include;%VCINSTALLDIR%\ATLMFC\INCLUDE;%VCINSTALLDIR%\INCLUDE;%VCINSTALLDIR%\VCPackages;%INCLUDE%
set LIB=%LINKERDIR%\LIB\x64;%VCINSTALLDIR%\LIB\amd64;%VCINSTALLDIR%\ATLMFC\LIB\amd64;%MATLAB%\extern\lib\win64;%LIB%
set MW_TARGET_ARCH=win64

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=cl
set OPTIMFLAGS=-O2 -DNDEBUG
rem Use -MDd when all DLLs in bin/win64 have embedded manifests.
set DEBUGFLAGS=-Z7 -MD
set VER_SPECIFIC_OPTS=/D_CRT_SECURE_NO_DEPRECATE
set CPPOPTIMFLAGS=-O2 -DNDEBUG
set CPPDEBUGFLAGS=-Z7 -MD
set COMPFLAGS=-c -Zp8 -GR -W3 -EHsc- -Zc:wchar_t- -nologo %VER_SPECIFIC_OPTS%
set CPPCOMPFLAGS=-c -Zp8 -GR  -W3 -EHsc- -Zc:wchar_t- -nologo -Zm500 -MD -I"%MATLAB%\extern\include\cpp" -DMSVC -DIBMPC /D_SECURE_SCL=0 %VER_SPECIFIC_OPTS%
set DLLCOMPFLAGS=-c -Zp8 -GR -EHsc- -Zc:wchar_t- -W3 -nologo -I"%MATLAB%\extern\include\win64" -DMSVC -DIBMPC %VER_SPECIFIC_OPTS%
rem set OPTIMFLAGS=/MD -O2 -Oy- -DNDEBUG
rem set DEBUGFLAGS=/MD -Zi -Fd"%OUTDIR%%MEX_NAME%%MEX_EXT%.pdb"
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Library creation commands creating import and export libraries
rem ********************************************************************
set DLL_MAKEDEF=type %BASE_EXPORTS_FILE% | %PERL% -e "print \"LIBRARY %MEX_NAME%.dll\nEXPORTS\n\"; while (<>) {print;}" > %DEF_FILE%

rem ********************************************************************
rem Linker parameters
rem MATLAB_EXTLIB is set automatically by mex.bat
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win64\microsoft
set LINKER=link
set MANIFEST_FILE_NAME=%OUTDIR%%MEX_NAME%.msvc.manifest
set LINKFLAGS=/MACHINE:AMD64 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /LIBPATH:"%LIBLOC%" /nologo /manifest /manifestfile:"%MANIFEST_FILE_NAME%" 
set LINKFLAGS=%LINKFLAGS% mclmcrrt.lib
set CPPLINKFLAGS=
set DLLLINKFLAGS= %LINKFLAGS% /dll /implib:"%OUTDIR%%MEX_NAME%.lib" /def:%DEF_FILE%
set HGLINKFLAGS=
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug
set LINK_FILE=
set LINK_LIB=
set EXE_OUTPUT_NAME="%OUTDIR%%MEX_NAME%.exe"
set DLL_OUTPUT_NAME="%OUTDIR%%MEX_NAME%.dll"
set NAME_OUTPUT=/out:%EXE_OUTPUT_NAME%
set DLL_NAME_OUTPUT=/out:%DLL_OUTPUT_NAME%
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Post link. Under MSVC 9, the runtime must be loaded by a manifest file.
rem MATLAB_EXTLIB is set automatically by mex.bat
rem ********************************************************************
set EXE_MANIFEST_RESOURCE=1
set DLL_MANIFEST_RESOURCE=2
set POSTLINK_CMDS1=mt.exe -outputresource:%MBUILD_OUTPUT_FILE_NAME%;%MANIFEST_RESOURCE% -manifest "%MANIFEST_FILE_NAME%"

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=rc /fo "%OUTDIR%%RES_NAME%.res"
set RC_LINKER= 

rem ********************************************************************
rem IDL Compiler
rem ********************************************************************
set IDL_COMPILER=midl /nologo /win64 /I "%MATLAB%\extern\include" 
set IDL_OUTPUTDIR= /out "%OUTDIRN%"
set IDL_DEBUG_FLAGS= /D "_DEBUG" 
set IDL_OPTIM_FLAGS= /D "NDEBUG" 
rem set POSTLINK_CMDS1=if exist %LIB_NAME%.def del %LIB_NAME%.def