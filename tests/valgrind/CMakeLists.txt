find_package(Qt${QT_MAJOR_VERSION_REQUIRED}Core QUIET)
if (Qt${QT_MAJOR_VERSION_REQUIRED}Core_FOUND)
	# Series of unit tests without memory leaks
	add_qt_test(NoLeakTest tst_noleak.cpp)
        target_link_libraries(NoLeakTest PUBLIC Qt${QT_MAJOR_VERSION_REQUIRED}::Test)

	# Series of unit tests with memory leaks
	add_qt_test(LeakTest tst_leak.cpp)
        target_link_libraries(LeakTest PUBLIC Qt${QT_MAJOR_VERSION_REQUIRED}::Test)
endif(Qt${QT_MAJOR_VERSION_REQUIRED}Core_FOUND)
