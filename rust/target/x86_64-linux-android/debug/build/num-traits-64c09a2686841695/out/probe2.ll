; ModuleID = 'probe2.f06e4965-cgu.0'
source_filename = "probe2.f06e4965-cgu.0"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-android"

; probe2::probe
; Function Attrs: nonlazybind uwtable
define void @_ZN6probe25probe17h4e4052b5c3a8bad6E() unnamed_addr #0 {
start:
  %0 = alloca i32, align 4
  store i32 -2147483648, ptr %0, align 4
  %1 = load i32, ptr %0, align 4
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.bitreverse.i32(i32) #1

attributes #0 = { nonlazybind uwtable "probe-stack"="__rust_probestack" "target-cpu"="x86-64" "target-features"="+mmx,+sse,+sse2,+sse3,+ssse3,+sse4.1,+sse4.2,+popcnt" }
attributes #1 = { nocallback nofree nosync nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1}

!0 = !{i32 7, !"PIC Level", i32 2}
!1 = !{i32 2, !"RtLibUseGOT", i32 1}
