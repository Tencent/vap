// QGVAPSafeMutableArray.m
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

#import "QGVAPSafeMutableArray.h"

#define VAP_INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_arr) return nil; \
_lock = [[NSRecursiveLock alloc] init]; \
return self;

#define VAP_LOCK(...) [_lock lock]; \
__VA_ARGS__; \
[_lock unlock];

@interface QGVAPSafeMutableArray (){

    NSMutableArray *_arr;
    NSRecursiveLock *_lock;
}

@end

@implementation QGVAPSafeMutableArray


#pragma mark - init

-(instancetype)init{
    VAP_INIT(_arr = [NSMutableArray new]);
}

-(instancetype)initWithCapacity:(NSUInteger)numItems{
    VAP_INIT(_arr = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

-(instancetype)initWithArray:(NSArray *)array{
    VAP_INIT(_arr = [[NSMutableArray alloc] initWithArray:array]);
}

-(instancetype)initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    VAP_INIT(_arr = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    VAP_INIT(_arr = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    VAP_INIT(_arr = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

#pragma mark - methods

- (NSUInteger)count {
    VAP_LOCK(NSUInteger count = _arr.count); return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    VAP_LOCK(id obj = [_arr objectAtIndex:index]); return obj;
}

- (NSArray *)arrayByAddingObject:(id)anObject {
    VAP_LOCK(NSArray * arr = [_arr arrayByAddingObject:anObject]); return arr;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    VAP_LOCK(NSArray * arr = [_arr arrayByAddingObjectsFromArray:otherArray]); return arr;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    VAP_LOCK(NSString * str = [_arr componentsJoinedByString:separator]); return str;
}

- (BOOL)containsObject:(id)anObject {
    VAP_LOCK(BOOL c = [_arr containsObject:anObject]); return c;
}

- (NSString *)description {
    VAP_LOCK(NSString * d = _arr.description); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    VAP_LOCK(NSString * d = [_arr descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    VAP_LOCK(NSString * d = [_arr descriptionWithLocale:locale indent:level]); return d;
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    VAP_LOCK(id o = [_arr firstObjectCommonWithArray:otherArray]); return o;
}

- (void)getObjects:(id __unsafe_unretained[])objects range:(NSRange)range {
    VAP_LOCK([_arr getObjects:objects range:range]);
}

- (NSUInteger)indexOfObject:(id)anObject {
    VAP_LOCK(NSUInteger i = [_arr indexOfObject:anObject]); return i;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    VAP_LOCK(NSUInteger i = [_arr indexOfObject:anObject inRange:range]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    VAP_LOCK(NSUInteger i = [_arr indexOfObjectIdenticalTo:anObject]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    VAP_LOCK(NSUInteger i = [_arr indexOfObjectIdenticalTo:anObject inRange:range]); return i;
}

- (id)firstObject {
    VAP_LOCK(id o = _arr.firstObject); return o;
}

- (id)lastObject {
    VAP_LOCK(id o = _arr.lastObject); return o;
}

- (NSEnumerator *)objectEnumerator {
    VAP_LOCK(NSEnumerator * e = [_arr objectEnumerator]); return e;
}

- (NSEnumerator *)reverseObjectEnumerator {
    VAP_LOCK(NSEnumerator * e = [_arr reverseObjectEnumerator]); return e;
}

- (NSData *)sortedArrayHint {
    VAP_LOCK(NSData * d = [_arr sortedArrayHint]); return d;
}

- (NSArray *)sortedArrayUsingFunction:(__attribute__((noescape)) NSInteger (*)(id, id, void *))comparator context:(void *)context {
    VAP_LOCK(NSArray * arr = [_arr sortedArrayUsingFunction:comparator context:context]) return arr;
}

- (NSArray *)sortedArrayUsingFunction:(__attribute__((noescape)) NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint {
    VAP_LOCK(NSArray * arr = [_arr sortedArrayUsingFunction:comparator context:context hint:hint]); return arr;
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    VAP_LOCK(NSArray * arr = [_arr sortedArrayUsingSelector:comparator]); return arr;
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    VAP_LOCK(NSArray * arr = [_arr subarrayWithRange:range]) return arr;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    VAP_LOCK([_arr makeObjectsPerformSelector:aSelector]);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    VAP_LOCK([_arr makeObjectsPerformSelector:aSelector withObject:argument]);
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    VAP_LOCK(NSArray * arr = [_arr objectsAtIndexes:indexes]); return arr;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    VAP_LOCK(id o = [_arr objectAtIndexedSubscript:idx]); return o;
}

- (void)enumerateObjectsUsingBlock:(__attribute__((noescape)) void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    VAP_LOCK([_arr enumerateObjectsUsingBlock:block]);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(__attribute__((noescape)) void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    VAP_LOCK([_arr enumerateObjectsWithOptions:opts usingBlock:block]);
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(__attribute__((noescape)) void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    VAP_LOCK([_arr enumerateObjectsAtIndexes:s options:opts usingBlock:block]);
}

- (NSUInteger)indexOfObjectPassingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSUInteger i = [_arr indexOfObjectPassingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSUInteger i = [_arr indexOfObjectWithOptions:opts passingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSUInteger i = [_arr indexOfObjectAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSIndexSet * i = [_arr indexesOfObjectsPassingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSIndexSet * i = [_arr indexesOfObjectsWithOptions:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(__attribute__((noescape)) BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    VAP_LOCK(NSIndexSet * i = [_arr indexesOfObjectsAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSArray *)sortedArrayUsingComparator:(__attribute__((noescape)) NSComparator)cmptr {
    VAP_LOCK(NSArray * a = [_arr sortedArrayUsingComparator:cmptr]); return a;
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(__attribute__((noescape)) NSComparator)cmptr {
    VAP_LOCK(NSArray * a = [_arr sortedArrayWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(__attribute__((noescape)) NSComparator)cmp {
    VAP_LOCK(NSUInteger i = [_arr indexOfObject:obj inSortedRange:r options:opts usingComparator:cmp]); return i;
}

#pragma mark - mutable

- (void)addObject:(id)anObject {
    VAP_LOCK([_arr addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    VAP_LOCK([_arr insertObject:anObject atIndex:index]);
}

- (void)removeLastObject {
    VAP_LOCK([_arr removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    VAP_LOCK([_arr removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    VAP_LOCK([_arr replaceObjectAtIndex:index withObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    VAP_LOCK([_arr addObjectsFromArray:otherArray]);
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    VAP_LOCK([_arr exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)removeAllObjects {
    VAP_LOCK([_arr removeAllObjects]);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    VAP_LOCK([_arr removeObject:anObject inRange:range]);
}

- (void)removeObject:(id)anObject {
    VAP_LOCK([_arr removeObject:anObject]);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    VAP_LOCK([_arr removeObjectIdenticalTo:anObject inRange:range]);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    VAP_LOCK([_arr removeObjectIdenticalTo:anObject]);
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    VAP_LOCK([_arr removeObjectsInArray:otherArray]);
}

- (void)removeObjectsInRange:(NSRange)range {
    VAP_LOCK([_arr removeObjectsInRange:range]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    VAP_LOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    VAP_LOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)setArray:(NSArray *)otherArray {
    VAP_LOCK([_arr setArray:otherArray]);
}

- (void)sortUsingFunction:(__attribute__((noescape)) NSInteger (*)(id, id, void *))compare context:(void *)context {
    VAP_LOCK([_arr sortUsingFunction:compare context:context]);
}

- (void)sortUsingSelector:(SEL)comparator {
    VAP_LOCK([_arr sortUsingSelector:comparator]);
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    VAP_LOCK([_arr insertObjects:objects atIndexes:indexes]);
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    VAP_LOCK([_arr removeObjectsAtIndexes:indexes]);
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    VAP_LOCK([_arr replaceObjectsAtIndexes:indexes withObjects:objects]);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    VAP_LOCK([_arr setObject:obj atIndexedSubscript:idx]);
}

- (void)sortUsingComparator:(__attribute__((noescape)) NSComparator)cmptr {
    VAP_LOCK([_arr sortUsingComparator:cmptr]);
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(__attribute__((noescape)) NSComparator)cmptr {
    VAP_LOCK([_arr sortWithOptions:opts usingComparator:cmptr]);
}

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (otherArray == self) return YES;
    if ([otherArray isKindOfClass:QGVAPSafeMutableArray.class]) {
        QGVAPSafeMutableArray *other = (id)otherArray;
        BOOL isEqual;
        [_lock lock];
        [other->_lock lock];
        isEqual = [_arr isEqualToArray:other->_arr];
        [other->_lock unlock];
        [_lock unlock];
        return isEqual;
    }
    return NO;
}

#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    VAP_LOCK(id copiedArr = [[self.class allocWithZone:zone] initWithArray:_arr]);
    return copiedArr;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    VAP_LOCK(NSUInteger count = [_arr countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:[QGVAPSafeMutableArray class]]) {
        QGVAPSafeMutableArray *other = object;
        BOOL isEqual;
        [_lock lock];
        [other->_lock lock];
        isEqual = [_arr isEqual:other->_arr];
        [other->_lock unlock];
        [_lock unlock];
        return isEqual;
    }
    return NO;
}

- (NSUInteger)hash {
    VAP_LOCK(NSUInteger hash = [_arr hash]);
    return hash;
}

@end
