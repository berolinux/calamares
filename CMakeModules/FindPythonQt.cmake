# Find PythonQt
#
# Sets PYTHONQT_FOUND, PYTHONQT_INCLUDE_DIR, PYTHONQT_LIBRARY, PYTHONQT_LIBRARIES
#
# Also sets:
#   - HAVE_PYTHONQT_CONSOLE if the scripting console headers are found
#   - PYTHONQT_INCLUDE_DIRS
#

# Python is required
find_package(PythonLibs)
if(NOT PYTHONLIBS_FOUND)
  message(FATAL_ERROR "error: Python is required to build PythonQt")
endif()

# Cut X.Y[.Z] down to just X.Y
string(REGEX REPLACE
    "^([0-9][0-9]*)\.([0-9][0-9]*)"
    "\\1.\\2@"
    _PYTHONLIBS_MAJMIN
    ${PYTHONLIBS_VERSION_STRING}
)
string(REGEX REPLACE
    "@.*"
    ""
    PYTHONLIBS_MAJMIN
    ${_PYTHONLIBS_MAJMIN}
)

if(NOT EXISTS "${PYTHONQT_INSTALL_DIR}")
  find_path(PYTHONQT_INSTALL_DIR include/PythonQt/PythonQt.h DOC "Directory where PythonQt was installed.")
endif()
# XXX Since PythonQt 3.0 is not yet cmakeified, depending
#     on how PythonQt is built, headers will not always be
#     installed in "include/PythonQt". That is why "src"
#     is added as an option. See [1] for more details.
#     [1] https://github.com/commontk/CTK/pull/538#issuecomment-86106367
find_path(PYTHONQT_INCLUDE_DIR PythonQt.h
  PATHS "${PYTHONQT_INSTALL_DIR}/include/PythonQt"
        "${PYTHONQT_INSTALL_DIR}/src"
  DOC "Path to the PythonQt include directory")

if ( NOT PythonQt_FIND_QUIETLY )
    message( STATUS "Searching for PythonQt (PythonLibs ${PYTHONLIBS_MAJMIN}) .." )
    if ( PYTHONQT_INCLUDE_DIR )
        message( STATUS "  .. found include ${PYTHONQT_INCLUDE_DIR}" )
    endif()
endif()

# Minimum v3.1 is needed
find_library(PYTHONQT_LIBRARY_RELEASE
    NAMES
        PythonQt-Qt5-Python${PYTHONLIBS_MAJMIN}
        PythonQt-Qt5-Python3
        PythonQt
    PATHS "${PYTHONQT_INSTALL_DIR}/lib"
    DOC "The PythonQt library."
)
find_library(PYTHONQT_LIBRARY_DEBUG
    NAMES
        PythonQt-Qt5-Python${PYTHONLIBS_MAJMIN}JMIN${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt-Qt5-Python${PYTHONLIBS_MAJMIN}${CMAKE_DEBUG_POSTFIX}
        PythonQt-Qt5-Python${PYTHONLIBS_MAJMIN}
        PythonQt-Qt5-Python3${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt-Qt5-Python3${CMAKE_DEBUG_POSTFIX}
        PythonQt-Qt5-Python3
        PythonQt${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt${CMAKE_DEBUG_POSTFIX}
        PythonQt
    PATHS "${PYTHONQT_INSTALL_DIR}/lib"
    DOC "The PythonQt library (debug build)."
)
find_library(PYTHONQT_QTALL_LIBRARY_RELEASE
    NAMES
        PythonQt_QtAll-Qt5-Python${PYTHONLIBS_MAJMIN}
        PythonQt_QtAll-Qt5-Python3
        PythonQt_QtAll
    PATHS "${PYTHONQT_INSTALL_DIR}/lib"
    DOC "Full Qt bindings for the PythonQt library."
)
find_library(PYTHONQT_QTALL_LIBRARY_DEBUG
    NAMES
        PythonQt_QtAll-Qt5-Python${PYTHONLIBS_MAJMIN}${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll-Qt5-Python${PYTHONLIBS_MAJMIN}${CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll-Qt5-Python${PYTHONLIBS_MAJMIN}
        PythonQt_QtAll-Qt5-Python3${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll-Qt5-Python3${CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll-Qt5-Python3
        PythonQt_QtAll${CTK_CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll${CMAKE_DEBUG_POSTFIX}
        PythonQt_QtAll
    PATHS "${PYTHONQT_INSTALL_DIR}/lib"
    DOC "Full Qt bindings for the PythonQt library (debug build)."
)

set(PYTHONQT_LIBRARY)
if(PYTHONQT_LIBRARY_RELEASE)
  list(APPEND PYTHONQT_LIBRARY optimized ${PYTHONQT_LIBRARY_RELEASE})
endif()
if(PYTHONQT_LIBRARY_DEBUG)
  list(APPEND PYTHONQT_LIBRARY debug ${PYTHONQT_LIBRARY_DEBUG})
endif()

set(PYTHONQT_QTALL_LIBRARY)
if(PYTHONQT_QTALL_LIBRARY_RELEASE)
  list(APPEND PYTHONQT_QTALL_LIBRARY optimized ${PYTHONQT_QTALL_LIBRARY_RELEASE})
endif()
if(PYTHONQT_QTALL_LIBRARY_DEBUG)
  list(APPEND PYTHONQT_QTALL_LIBRARY debug ${PYTHONQT_QTALL_LIBRARY_DEBUG})
endif()

if ( NOT PythonQt_FIND_QUIETLY )
    if ( PYTHONQT_LIBRARY )
        message( STATUS "  .. found library ${PYTHONQT_LIBRARY}" )
    endif()
    if ( PYTHONQT_QTALL_LIBRARY )
        message( STATUS "  .. found qtall   ${PYTHONQT_QTALL_LIBRARY}" )
    endif()
endif()


mark_as_advanced(PYTHONQT_INSTALL_DIR)
mark_as_advanced(PYTHONQT_INCLUDE_DIR)
mark_as_advanced(PYTHONQT_LIBRARY_RELEASE)
mark_as_advanced(PYTHONQT_LIBRARY_DEBUG)
mark_as_advanced(PYTHONQT_QTALL_LIBRARY_RELEASE)
mark_as_advanced(PYTHONQT_QTALL_LIBRARY_DEBUG)

# On linux, also find libutil
if(UNIX AND NOT APPLE)
  find_library(PYTHONQT_LIBUTIL util)
  mark_as_advanced(PYTHONQT_LIBUTIL)
endif()

# All upper case _FOUND variable is maintained for backwards compatibility.
set(PYTHONQT_FOUND 0)
set(PythonQt_FOUND 0)

if(PYTHONQT_INCLUDE_DIR AND PYTHONQT_LIBRARY AND PYTHONQT_QTALL_LIBRARY)
  # Currently CMake'ified PythonQt only supports building against a python Release build.
  # This applies independently of CTK build type (Release, Debug, ...)
  add_definitions(-DPYTHONQT_USE_RELEASE_PYTHON_FALLBACK)
  set(PYTHONQT_FOUND 1)
  set(PythonQt_FOUND ${PYTHONQT_FOUND})
  set(PYTHONQT_LIBRARIES ${PYTHONQT_LIBRARY} ${PYTHONQT_LIBUTIL} ${PYTHONQT_QTALL_LIBRARY})
  set(PYTHONQT_INCLUDE_DIRS ${PYTHONQT_INCLUDE_DIR})
elseif(NOT PythonQt_FIND_QUIETLY)
  set(_missing "")
  if (NOT PYTHONQT_INCLUDE_DIR)
    list(APPEND _missing "includes")
  endif()
  if (NOT PYTHONQT_LIBRARY)
    list(APPEND _missing "library")
  endif()
  if (NOT PYTHONQT_QTALL_LIBRARY)
    list(APPEND _missing "qtall")
  endif()
  message(STATUS "PythonQt not found, missing components ${_missing}")
endif()

if(PYTHONQT_FOUND)
    # Handle variations in PythonQt packaging
    find_file( HAVE_PYTHONQT_CONSOLE gui/PythonQtScriptingConsole.h HINTS ${PYTHONQT_INCLUDE_DIR} )
    find_file( _qtall_header PythonQt_QtAll.h
        HINTS
            ${PYTHONQT_INCLUDE_DIR}/extensions/PythonQt_QtAll/
            ${PYTHONQT_INCLUDE_DIR}
    )
    message( STATUS "PythonQt:\n\tConsole ${HAVE_PYTHONQT_CONSOLE}\n\tAll     ${_qtall_header}" )
    file( RELATIVE_PATH _qtall_subdir ${PYTHONQT_INCLUDE_DIR} ${_qtall_header} )

    if ( NOT _qtall_header )
        message( FATAL_ERROR "No PythonQt_QtAll.h found." )
    elseif ( _qtall_header STREQUAL "PythonQt_QtAll.h" )
        # It's in the main include directory, nothing to do
        message( STATUS "PythonQt_QtAll.h found in ${PYTHONQT_INCLUDE_DIR}" )
    else()
        get_filename_component( _qtall_subdir "${_qtall_subdir}" DIRECTORY )
        list( APPEND PYTHONQT_INCLUDE_DIRS ${PYTHONQT_INCLUDE_DIR}/${_qtall_subdir} )
    endif()
endif()
