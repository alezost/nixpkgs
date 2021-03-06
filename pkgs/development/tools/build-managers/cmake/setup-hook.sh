addCMakeParams()
{
    addToSearchPath CMAKE_PREFIX_PATH $1
}

fixCmakeFiles()
{
    local replaceArgs
    echo "fixing cmake files"
    replaceArgs="-e -f -L -T /usr /var/empty -a /opt /var/empty"
    find $1 -type f -name "*.cmake" -o -name "*.cmake.in" -o -name CMakeLists.txt -print0 |
        xargs -0 replace-literal ${replaceArgs}
}

cmakeConfigurePhase()
{
    eval "$preConfigure"

    if test -z "$dontFixCmake"; then
        fixCmakeFiles .
    fi

    if test -z "$dontUseCmakeBuildDir"; then
        mkdir -p build
        cd build
        cmakeDir=..
    fi

    if test -z "$dontAddPrefix"; then
        cmakeFlags="-DCMAKE_INSTALL_PREFIX=$prefix $cmakeFlags"
    fi

    if test -n "$crossConfig"; then
        # By now it supports linux builds only. We should set the proper
        # CMAKE_SYSTEM_NAME otherwise.
        # http://www.cmake.org/Wiki/CMake_Cross_Compiling
        cmakeFlags="-DCMAKE_CXX_COMPILER=$crossConfig-g++ -DCMAKE_C_COMPILER=$crossConfig-gcc $cmakeFlags"
    fi

    # Avoid cmake resetting the rpath of binaries, on make install
    cmakeFlags="-DCMAKE_SKIP_BUILD_RPATH=ON $cmakeFlags"

    echo "cmake flags: $cmakeFlags ${cmakeFlagsArray[@]}"

    cmake ${cmakeDir:-.} $cmakeFlags ${cmakeFlagsArray[@]}

    eval "$postConfigure"
}

if test -z "$dontUseCmakeConfigure"; then
    configurePhase=cmakeConfigurePhase
fi

if test -n "$crossConfig"; then
    crossEnvHooks+=(addCMakeParams)
else
    envHooks+=(addCMakeParams)
fi
