@ECHO OFF
for /f "delims=" %%i in ('where love') do set "love=%%~dpi"
for %%I in (".") do set "cur=%%~fI"

rmdir "build/output" /s /q
md "build/output"

echo Compressing the game...
powershell Compress-Archive -LiteralPath 'assets','engine','src','sti','main.lua' -Force -DestinationPath 'build/output/Ambisense'

cd "build/output"
ren "Ambisense.zip" "Ambisense.love"

echo Building the windows version...
if not exist windows ( md windows )
copy /b "%love%/love.exe"+"Ambisense.love" "windows/Ambisense.exe"
copy "%love%/*.dll" "windows"
copy "%love%/license.txt" "windows/LICENSE"

echo Building the android version...
if not exist android ( md android )
call apktool d -s -f -o "android/love_decoded" "%love%/love-android-embed.apk"
md "android/love_decoded/assets"
copy "Ambisense.love" "android/love_decoded/assets/game.love"
call lua54 "../manifest/generate.lua" "%cur%"
move /y "../manifest/AndroidManifest.xml" "android/love_decoded"
call apktool b -o "android/Ambisense.apk" "android/love_decoded"

if exist "Ambisense.zip" ( del "Ambisense.zip" )