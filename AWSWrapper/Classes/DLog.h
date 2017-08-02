//
//  DLog.h
//  Pods
//
//  Created by Stan Liu on 02/08/2017.
//
//


#define debugMode YES;

#ifdef debugMode
#  define DLOG(format, ...) NSLog((@":NR: %s (L: %d) " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#  define DLOG(format, ...)
#endif
