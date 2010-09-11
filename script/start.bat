set JAVA_HOME=c:\program files\java\jre6
set JAVA_BIN=%JAVA_HOME%\bin\java.exe

echo "" > timestamp.txt

"%JAVA_BIN%" -jar lib\jruby-complete.jar -e "require 'lib/jruby_boot'"
