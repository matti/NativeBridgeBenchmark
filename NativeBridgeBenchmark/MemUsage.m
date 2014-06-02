//
//  MemUsage.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/06/14.
//
//

#import "MemUsage.h"
#import <mach/mach.h>


@implementation MemUsage

static long prevMemUsage = 0;
static long curMemUsage = 0;
static long memUsageDiff = 0;
static long curFreeMem = 0;

-(vm_size_t) freeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;

    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

-(vm_size_t) usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

-(void) captureMemUsage {
    prevMemUsage = curMemUsage;
    curMemUsage = [self usedMemory];
    memUsageDiff = curMemUsage - prevMemUsage;
    curFreeMem = [self freeMemory];


}

-(NSString*) memUsageString{
//    return [self captureMemUsageGetString: @"Memory used %7.1f (%+5.0f), free %7.1f kb"];
    return [self captureMemUsageGetString: @"%7.1f"];
}

-(NSString*) captureMemUsageGetString:(NSString*) formatstring {
    [self captureMemUsage];
    return [NSString stringWithFormat:formatstring,curMemUsage/1000.0f];
    //    return [NSString stringWithFormat:formatstring,curMemUsage/1000.0f, memUsageDiff/1000.0f, curFreeMem/1000.0f];

}

@end
