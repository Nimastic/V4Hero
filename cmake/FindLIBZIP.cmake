# Custom FindLIBZIP.cmake
# When libzip is built via FetchContent (i.e. libzip::zip target already exists),
# we skip the system search entirely and just report the target as found.
# This makes the build fully self-contained and cross-architecture on macOS.

if (TARGET libzip::zip)
    set(LIBZIP_FOUND TRUE)
    set(_libzip_pkgcfg "INTERNAL_FETCHCONTENT")

    if(NOT LIBZIP_INCLUDE_DIR)
        get_target_property(_libzip_iface libzip::zip INTERFACE_INCLUDE_DIRECTORIES)
        if(_libzip_iface)
            set(LIBZIP_INCLUDE_DIR "${_libzip_iface}")
        else()
            set(LIBZIP_INCLUDE_DIR "${libzip_src_SOURCE_DIR}/lib")
        endif()
    endif()

    if(NOT LIBZIP_LIBRARY)
        set(LIBZIP_LIBRARY zip)
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(LIBZIP
        REQUIRED_VARS LIBZIP_LIBRARY LIBZIP_INCLUDE_DIR _libzip_pkgcfg)
else()
    # Fallback: original system search (Linux / Windows where libzip is installed)
    find_package(ZLIB REQUIRED)

    find_path(LIBZIP_INCLUDE_DIR NAMES zip.h)
    mark_as_advanced(LIBZIP_INCLUDE_DIR)

    find_library(LIBZIP_LIBRARY NAMES zip)
    mark_as_advanced(LIBZIP_LIBRARY)

    get_filename_component(_libzip_libdir ${LIBZIP_LIBRARY} DIRECTORY)
    find_file(_libzip_pkgcfg libzip.pc
        HINTS ${_libzip_libdir} ${LIBZIP_INCLUDE_DIR}/..
        PATH_SUFFIXES pkgconfig lib/pkgconfig libdata/pkgconfig
        NO_DEFAULT_PATH)

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(LIBZIP
        REQUIRED_VARS LIBZIP_LIBRARY LIBZIP_INCLUDE_DIR _libzip_pkgcfg)

    if (LIBZIP_FOUND AND NOT TARGET libzip::zip)
        add_library(libzip::zip UNKNOWN IMPORTED)
        set_target_properties(libzip::zip PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${LIBZIP_INCLUDE_DIR}"
            INTERFACE_LINK_LIBRARIES ZLIB::ZLIB
            IMPORTED_LOCATION "${LIBZIP_LIBRARY}")

        file(STRINGS ${_libzip_pkgcfg} _have_extra_libs REGEX Libs)
        if(_have_extra_libs MATCHES "-lbz2")
            find_package(BZip2 REQUIRED)
            set_property(TARGET libzip::zip APPEND PROPERTY INTERFACE_LINK_LIBRARIES BZip2::BZip2)
        endif()
        if(_have_extra_libs MATCHES "-llzma")
            find_package(LibLZMA REQUIRED)
            set_property(TARGET libzip::zip APPEND PROPERTY INTERFACE_LINK_LIBRARIES LibLZMA::LibLZMA)
        endif()
    endif()
endif()
