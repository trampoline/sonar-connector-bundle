; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "Sonar Connector"
!define PRODUCT_VERSION "0.6.6"
!define PRODUCT_PUBLISHER "Trampoline Systems"
!define PRODUCT_WEB_SITE "http://www.trampolinesystems.com"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "StrRep.nsh"
!include "ReplaceInFile.nsh"
  
; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

# Variables
Var dialog
Var label
Var browseButton
Var jreDirRequest
Var toolkitDirRequest
Var jreDir
Var toolkitDir

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "..\build\SonarConnector\LICENSE"

; Locate the Server Resource Kit - we need this to continue
Page custom jrePageCreate jrePageLeave

; Locate the Server Toolkit
Page custom toolkitPageCreate toolkitPageLeave

; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\build\SonarConnectorSetup.exe"
InstallDir "$PROGRAMFILES\Sonar Connector"
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01

  SetOutPath "$INSTDIR\"
  SetOverwrite try
  
  DetailPrint "Stopping service..."
  ExecWait "cmd.exe /C net stop SonarConnector" $0
  DetailPrint " ... exit code = $0"
  
  DetailPrint "Removing service..."
  ExecWait '"$toolkitDir\instsrv.exe" SonarConnector REMOVE' $0
  DetailPrint '... exit code = $0'
  
  File /r "..\build\SonarConnector\"
  
  # Shortened file list for debugging
  # File /r "..\build\SonarConnector\script"
  # File /r "..\build\SonarConnector\template"

  DetailPrint "Creating service..."
  ExecWait '"$toolkitDir\instsrv.exe" SonarConnector "$toolkitDir\srvany.exe"' $0
  DetailPrint " ... exit code = $0"

  # Write registry keys for srvany.exe startup parameters
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\SonarConnector" "Description" "Trampoline Systems Sonar Connector"
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\SonarConnector\Parameters" "AppDirectory" "$INSTDIR"
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\services\SonarConnector\Parameters" "Application" `"$jreDir\bin\java.exe" -jar lib\jruby-complete.jar -e "require 'lib/jruby_boot'"`
  
  # Write a new start.bat file and do inline replace on java_home var
  
  CopyFiles $INSTDIR\template\start.bat $INSTDIR\script\start.bat
  !insertmacro ReplaceInFile "$INSTDIR\script\start.bat" "{{java_home}}" $jreDir
  
  # Start the service
  DetailPrint "Starting service..."
  ExecWait "cmd.exe /C net start SonarConnector" $0
  DetailPrint '... exit code = $0'

SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd



Function jrePageCreate
  nsDialogs::Create 1018
	Pop $dialog
	
	#Caption "Locate JRE"
  #SubCaption "The Java JRE is a prerequisite for the Sonar Connector. Please locate it on disk."

	${If} $dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 12u "Please locate the JAVA_HOME directory"
	Pop $label

  # Try to populate jreDirRequest with JAVA_HOME env variable
  ReadEnvStr $jreDir "JAVA_HOME"
  
	${NSD_CreateDirRequest} 20 70 248 20 $jreDir
  Pop $jreDirRequest
 
  ${NSD_CreateBrowseButton} 270 69 50 20 "Browse"
  Pop $browseButton
  ${NSD_OnClick} $browseButton OnJreDirBrowseButton
	
	nsDialogs::Show
FunctionEnd


Function OnJreDirBrowseButton
  Pop $R0
  ${If} $R0 == $browseButton
    ${NSD_GetText} $jreDirRequest $R0
    nsDialogs::SelectFolderDialog /NOUNLOAD "" $R0
    Pop $R0

    ${If} $R0 != error
      ${NSD_SetText} $jreDirRequest "$R0"
    ${EndIf}

  ${EndIf}
FunctionEnd

Function jrePageLeave
  ${NSD_GetText} $jreDirRequest $jreDir
  
  ${If} $jreDir == ""
    MessageBox mb_iconstop "Please choose a directory."
    Abort
  ${EndIf}
  ${IfNot} ${FileExists} "$jreDir\bin\java.exe"
    MessageBox mb_iconstop "$jreDir\bin\java.exe not found - incorrect JAVA_HOME dir."
    Abort
  ${EndIf}
FunctionEnd


Function toolkitPageCreate
  nsDialogs::Create 1018
	Pop $dialog

  #Caption "Locate the Windows Server Resource Kit"
  #SubCaption "The Windows Server Resource Kit is a prerequisite for the Sonar Connector. Please locate it."

	${If} $dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 0 0 100% 40 "Please locate the installation directory of the Windows Server Resource Kit."
	Pop $label

	${NSD_CreateDirRequest} 20 90 248 20 "C:\Program Files (x86)\Windows Resource Kits\Tools"
  Pop $toolkitDirRequest

  ${NSD_CreateBrowseButton} 270 89 50 20 "Browse"
  Pop $browseButton
  ${NSD_OnClick} $browseButton OnToolkitDirBrowseButton

	nsDialogs::Show
FunctionEnd


Function OnToolkitDirBrowseButton
  Pop $R0
  ${If} $R0 == $browseButton
    ${NSD_GetText} $toolkitDirRequest $R0
    nsDialogs::SelectFolderDialog /NOUNLOAD "" $R0
    Pop $R0

    ${If} $R0 != error
      ${NSD_SetText} $toolkitDirRequest "$R0"
    ${EndIf}

  ${EndIf}
FunctionEnd


Function toolkitPageLeave
  ${NSD_GetText} $toolkitDirRequest $toolkitDir
  
  ${If} $toolkitDir == ""
    MessageBox mb_iconstop "Please choose a directory."
    Abort
  ${EndIf}
  ${IfNot} ${FileExists} "$toolkitDir\srvany.exe"
    MessageBox mb_iconstop "$toolkitDir\srvany.exe not found - incorrect toolkit dir."
    Abort
  ${EndIf}
    ${IfNot} ${FileExists} "$toolkitDir\instsrv.exe"
    MessageBox mb_iconstop "$toolkitDir\instsrv.exe not found - incorrect toolkit dir."
    Abort
  ${EndIf}
FunctionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\*"
  RMDir /r "$INSTDIR\*"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd