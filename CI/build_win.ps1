
$COMPILER=$Env:COMPILER
$ARCH=$Env:ARCH

$src_dir=$pwd

if ($ARCH -eq "Win32") {
	echo "Running cmake for $COMPILER on 32 bit..."
	mkdir build-win32
	cp .\libiio.iss.cmakein .\build-win32
	cd build-win32

	cmake -G "$COMPILER" -A "$ARCH" -DENABLE_IPV6=OFF -DWITH_USB_BACKEND=OFF -DWITH_SERIAL_BACKEND=OFF -DPYTHON_BINDINGS=ON -DCSHARP_BINDINGS:BOOL=ON -DLIBXML2_LIBRARIES="$src_dir\deps\lib\libxml2.dll.a" ..
	cmake --build . --config Release
	cp .\libiio.iss $env:BUILD_ARTIFACTSTAGINGDIRECTORY

	cd ../bindings/python
	python.exe setup.py.cmakein sdist
	Get-ChildItem dist\pylibiio-*.tar.gz | Rename-Item -NewName "libiio-py39-win32.tar.gz"
	mv .\dist\*.gz .
	rm .\dist\*.gz
}else {
        echo "Running cmake for $COMPILER on 64 bit..."
        mkdir build-x64
	cp .\libiio.iss.cmakein .\build-x64
        cd build-x64

        cmake -G "$COMPILER" -A "$ARCH" -DENABLE_IPV6=OFF -DWITH_USB_BACKEND=OFF -DWITH_SERIAL_BACKEND=OFF -DPYTHON_BINDINGS=ON -DCSHARP_BINDINGS:BOOL=ON -DLIBXML2_LIBRARIES="$src_dir\deps\lib\libxml2.dll.a" ..
        cmake --build . --config Release
	cp .\libiio.iss $env:BUILD_ARTIFACTSTAGINGDIRECTORY

	cd ../bindings/python
        python.exe setup.py.cmakein sdist
        Get-ChildItem dist\pylibiio-*.tar.gz | Rename-Item -NewName "libiio-py39-amd64.tar.gz"
        mv .\dist\*.gz .
        rm .\dist\*.gz
}
