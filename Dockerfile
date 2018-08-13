FROM microsoft/windowsservercore

RUN powershell (new-object System.Net.WebClient).Downloadfile('http://javadl.oracle.com/webapps/download/AutoDL?BundleId=210185', 'C:\jre-8u91-windows-x64.exe')
RUN powershell start-process -filepath C:\jre-8u91-windows-x64.exe -passthru -wait -argumentlist "/s,INSTALLDIR=c:\Java\jre1.8.0_91,/L,install64.log"
RUN del C:\jre-8u91-windows-x64.exe
RUN setx -m JAVA_HOME 'C:\Java\jre1.8.0_91\bin'
RUN setx path '%path%;C:\Java\jre1.8.0_91'

RUN powershell -NoProfile -Command New-Item -Name Solr -Path C:\ -ItemType Directory

WORKDIR C:\\Solr

COPY solr-ssl.keystore.pfx .
COPY solr-install.ps1 .

RUN certutil -p secret -importpfx ROOT .\solr-ssl.keystore.pfx
RUN powershell.exe -executionpolicy bypass .\solr-install.ps1

CMD ["C:\\Solr\\solr-6.6.2\\bin\\solr.cmd -f"]