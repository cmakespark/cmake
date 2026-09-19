find_package(Qt6Core QUIET)
if (Qt6Core_FOUND)
	# Series of unit tests without memory leaks
	add_qt_test(NoLeakTest tst_noleak.cpp)
	target_link_libraries(NoLeakTest PUBLIC Qt6::Test)

	# Series of unit tests with memory leaks
	add_qt_test(LeakTest tst_leak.cpp)
	target_link_libraries(LeakTest PUBLIC Qt6::Test)
endif(Qt6Core_FOUND)
