//
//  DDTLog.h
//  Pods
//
//  Created by Stan Liu on 02/08/2017.
//
//

#ifdef debugMode
#  define DDTLog(format, ...) NSLog((@":NR: %s (L: %d) " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#  define DDTLog(format, ...)
#endif
