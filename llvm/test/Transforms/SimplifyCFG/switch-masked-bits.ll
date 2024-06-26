; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 < %s | FileCheck %s

define i32 @test1(i32 %x) nounwind {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  common.ret:
; CHECK-NEXT:    [[I:%.*]] = shl i32 [[X:%.*]], 1
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[I]], 24
; CHECK-NEXT:    [[DOT:%.*]] = select i1 [[COND]], i32 5, i32 0
; CHECK-NEXT:    ret i32 [[DOT]]
;
  %i = shl i32 %x, 1
  switch i32 %i, label %a [
  i32 21, label %b
  i32 24, label %c
  ]

a:
  ret i32 0
b:
  ret i32 3
c:
  ret i32 5
}


define i32 @test2(i32 %x) nounwind {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  a:
; CHECK-NEXT:    ret i32 0
;
  %i = shl i32 %x, 1
  switch i32 %i, label %a [
  i32 21, label %b
  i32 23, label %c
  ]

a:
  ret i32 0
b:
  ret i32 3
c:
  ret i32 5
}

; We're sign extending an 8-bit value.
; The switch condition must be in the range [-128, 127], so any cases outside of that range must be dead.

define i1 @repeated_signbits(i8 %condition) {
; CHECK-LABEL: @repeated_signbits(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SEXT:%.*]] = sext i8 [[CONDITION:%.*]] to i32
; CHECK-NEXT:    switch i32 [[SEXT]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:      i32 0, label [[COMMON_RET:%.*]]
; CHECK-NEXT:      i32 127, label [[COMMON_RET]]
; CHECK-NEXT:      i32 -128, label [[COMMON_RET]]
; CHECK-NEXT:      i32 -1, label [[COMMON_RET]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    [[COMMON_RET_OP:%.*]] = phi i1 [ false, [[DEFAULT]] ], [ true, [[ENTRY:%.*]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ], [ true, [[ENTRY]] ]
; CHECK-NEXT:    ret i1 [[COMMON_RET_OP]]
; CHECK:       default:
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  %sext = sext i8 %condition to i32
  switch i32 %sext, label %default [
  i32 -2147483648, label %a
  i32 -129, label %a
  i32 -128, label %a
  i32 -1, label %a
  i32  0, label %a
  i32  127, label %a
  i32  128, label %a
  i32  2147483647, label %a
  ]

a:
  ret i1 1

default:
  ret i1 0
}

