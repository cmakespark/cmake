find_package(Qt5Core QUIET)
if (Qt5Core_FOUND)
	# Series of unit tests without memory leaks
	add_qt_test(NoLeakTest tst_noleak.cpp)
	target_link_libraries(NoLeakTest PUBLIC Qt5::Test)

	# Series of unit tests with memory leaks
	add_qt_test(LeakTest tst_leak.cpp)
	target_link_libraries(LeakTest PUBLIC Qt5::Test)
endif(Qt5Core_FOUND)
