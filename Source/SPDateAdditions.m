//
//  SPDateAdditions.m
//  sequel-pro
//
//  Created by Rowan Beentje (rowan.beent.je) on February 22, 2012.
//  Copyright (c) 2012 Rowan Beentje. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  More info at <https://github.com/sequelpro/sequelpro>

#include <mach/mach_time.h>
#include "SPDateAdditions.h"

@implementation NSDate (SPDateAdditions)

/**
 * Retrieve a monotonic time for timing purposes: a value of a number of seconds
 * which can be use for relative time comparison in a monotonic sense, eg in a 
 * particular session this value will only ever increase linearly.
 * This differs from (for example) unix epoch timestamps or dates, which can change
 * when the system time changes or synchs, but should never be used for absolute time
 * as it is based on the elapsed time since the system booted.
 */
+ (double)monotonicTimeInterval
{
	
	uint64_t elapsedNano;
    static mach_timebase_info_data_t sTimebaseInfo;
	uint64_t elapsedTime_t = mach_absolute_time();

	// see: https://developer.apple.com/library/archive/qa/qa1398/_index.html
	// Convert to nanoseconds.

    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is
    // uninitialised because it makes no sense to have a zero
    // denominator is a fraction.

    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
	
    // Do the maths. We hope that the multiplication doesn't
    // overflow; the price you pay for working in fixed point.

    elapsedNano = elapsedTime_t * sTimebaseInfo.numer / sTimebaseInfo.denom;

    return (double)(elapsedNano * 1e-9);
	
}


/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone and locale
 *
 *  @param format   NSString - String representing the desired date format
 *  @param timeZone NSTimeZone - Desired time zone
 *  @param locale   NSLocale - Desired locale
 *
 *  @return NSString representing the formatted date string
 */
-(NSString *)formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });

    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}


@end
