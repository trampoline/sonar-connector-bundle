set JAVA_HOME={{java_home}}
set JAVA_BIN=%JAVA_HOME%\bin\java.exe
echo "" > timestamp.txt
"%JAVA_BIN%" -jar lib\jruby-complete.jar -e "require 'lib/jruby_boot'"
