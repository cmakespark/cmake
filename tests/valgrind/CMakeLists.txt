if (DEFINED QTDIR)
	# Series of unit tests without memory leaks
	add_qt_test(NoLeakTest tst_noleak.cpp)
	target_link_libraries(NoLeakTest PUBLIC Qt5::Test)

	# Series of unit tests with memory leaks
	add_qt_test(LeakTest tst_leak.cpp)
	target_link_libraries(LeakTest PUBLIC Qt5::Test)
endif(DEFINED QTDIR)
