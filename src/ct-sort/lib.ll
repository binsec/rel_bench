; ModuleID = 'lib.c'
source_filename = "lib.c"
target datalayout = "e-m:e-p:32:32-p270:32:32-p271:32:32-p272:64:64-f64:32:64-f80:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local i32 @sort2(i32* nocapture %0, i32* nocapture readonly %1) local_unnamed_addr #0 {
  %3 = load i32, i32* %1, align 4, !tbaa !5
  %4 = getelementptr inbounds i32, i32* %1, i32 1
  %5 = load i32, i32* %4, align 4, !tbaa !5
  %6 = icmp slt i32 %3, %5
  %7 = select i1 %6, i32 %3, i32 %5
  store i32 %7, i32* %0, align 4, !tbaa !5
  %8 = load i32, i32* %4, align 4
  %9 = load i32, i32* %1, align 4
  %10 = select i1 %6, i32 %8, i32 %9
  %11 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %10, i32* %11, align 4
  %12 = zext i1 %6 to i32
  ret i32 %12
}

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local void @sort3(i32* nocapture %0, i32* nocapture %1, i32* nocapture %2) local_unnamed_addr #0 {
  %4 = load i32, i32* %2, align 4, !tbaa !5
  %5 = getelementptr inbounds i32, i32* %2, i32 1
  %6 = load i32, i32* %5, align 4, !tbaa !5
  %7 = icmp slt i32 %4, %6
  %8 = select i1 %7, i32 %4, i32 %6
  store i32 %8, i32* %1, align 4, !tbaa !5
  %9 = load i32, i32* %5, align 4
  %10 = load i32, i32* %2, align 4
  %11 = select i1 %7, i32 %9, i32 %10
  %12 = getelementptr inbounds i32, i32* %1, i32 1
  store i32 %11, i32* %12, align 4
  %13 = zext i1 %7 to i32
  store i32 %13, i32* %0, align 4, !tbaa !5
  %14 = load i32, i32* %12, align 4, !tbaa !5
  store i32 %14, i32* %5, align 4, !tbaa !5
  %15 = getelementptr inbounds i32, i32* %2, i32 2
  %16 = load i32, i32* %15, align 4, !tbaa !5
  %17 = icmp slt i32 %14, %16
  %18 = select i1 %17, i32 %14, i32 %16
  store i32 %18, i32* %12, align 4, !tbaa !5
  %19 = load i32, i32* %15, align 4
  %20 = load i32, i32* %5, align 4
  %21 = select i1 %17, i32 %19, i32 %20
  %22 = getelementptr inbounds i32, i32* %1, i32 2
  store i32 %21, i32* %22, align 4
  %23 = zext i1 %17 to i32
  %24 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %23, i32* %24, align 4, !tbaa !5
  %25 = load i32, i32* %1, align 4, !tbaa !5
  store i32 %25, i32* %2, align 4, !tbaa !5
  %26 = load i32, i32* %12, align 4, !tbaa !5
  store i32 %26, i32* %5, align 4, !tbaa !5
  %27 = icmp slt i32 %25, %26
  %28 = select i1 %27, i32 %25, i32 %26
  store i32 %28, i32* %1, align 4, !tbaa !5
  %29 = load i32, i32* %5, align 4
  %30 = load i32, i32* %2, align 4
  %31 = select i1 %27, i32 %29, i32 %30
  store i32 %31, i32* %12, align 4
  %32 = zext i1 %27 to i32
  %33 = getelementptr inbounds i32, i32* %0, i32 2
  store i32 %32, i32* %33, align 4, !tbaa !5
  ret void
}

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local void @sort2_multiplex(i32* nocapture %0, i32* nocapture readonly %1) local_unnamed_addr #0 {
  %3 = load i32, i32* %1, align 4, !tbaa !5
  %4 = getelementptr inbounds i32, i32* %1, i32 1
  %5 = load i32, i32* %4, align 4, !tbaa !5
  %6 = icmp slt i32 %3, %5
  %7 = select i1 %6, i32 %3, i32 %5
  store i32 %7, i32* %0, align 4, !tbaa !5
  %8 = load i32, i32* %4, align 4, !tbaa !5
  %9 = load i32, i32* %1, align 4, !tbaa !5
  %10 = select i1 %6, i32 %8, i32 %9
  %11 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %10, i32* %11, align 4, !tbaa !5
  ret void
}

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local void @sort3_multiplex(i32* nocapture %0, i32* nocapture %1) local_unnamed_addr #0 {
  %3 = load i32, i32* %1, align 4, !tbaa !5
  %4 = getelementptr inbounds i32, i32* %1, i32 1
  %5 = load i32, i32* %4, align 4, !tbaa !5
  %6 = icmp slt i32 %3, %5
  %7 = select i1 %6, i32 %3, i32 %5
  store i32 %7, i32* %0, align 4, !tbaa !5
  %8 = load i32, i32* %4, align 4, !tbaa !5
  %9 = load i32, i32* %1, align 4, !tbaa !5
  %10 = select i1 %6, i32 %8, i32 %9
  %11 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %10, i32* %11, align 4, !tbaa !5
  store i32 %10, i32* %4, align 4, !tbaa !5
  %12 = getelementptr inbounds i32, i32* %1, i32 2
  %13 = load i32, i32* %12, align 4, !tbaa !5
  %14 = icmp slt i32 %10, %13
  %15 = select i1 %14, i32 %10, i32 %13
  store i32 %15, i32* %11, align 4, !tbaa !5
  %16 = load i32, i32* %12, align 4, !tbaa !5
  %17 = load i32, i32* %4, align 4, !tbaa !5
  %18 = select i1 %14, i32 %16, i32 %17
  %19 = getelementptr inbounds i32, i32* %0, i32 2
  store i32 %18, i32* %19, align 4, !tbaa !5
  %20 = load i32, i32* %0, align 4, !tbaa !5
  store i32 %20, i32* %1, align 4, !tbaa !5
  %21 = load i32, i32* %11, align 4, !tbaa !5
  store i32 %21, i32* %4, align 4, !tbaa !5
  %22 = icmp slt i32 %20, %21
  %23 = select i1 %22, i32 %20, i32 %21
  store i32 %23, i32* %0, align 4, !tbaa !5
  %24 = load i32, i32* %4, align 4, !tbaa !5
  %25 = load i32, i32* %1, align 4, !tbaa !5
  %26 = select i1 %22, i32 %24, i32 %25
  store i32 %26, i32* %11, align 4, !tbaa !5
  ret void
}

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local void @sort2_negative(i32* nocapture %0, i32* nocapture readonly %1) local_unnamed_addr #0 {
  %3 = load i32, i32* %1, align 4, !tbaa !5
  %4 = getelementptr inbounds i32, i32* %1, i32 1
  %5 = load i32, i32* %4, align 4, !tbaa !5
  %6 = icmp slt i32 %3, %5
  %7 = select i1 %6, i32 %3, i32 %5
  store i32 %7, i32* %0, align 4, !tbaa !5
  %8 = load i32, i32* %4, align 4
  %9 = load i32, i32* %1, align 4
  %10 = select i1 %6, i32 %8, i32 %9
  %11 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %10, i32* %11, align 4
  ret void
}

; Function Attrs: nofree norecurse nounwind sspstrong
define dso_local void @sort3_negative(i32* nocapture %0, i32* nocapture %1) local_unnamed_addr #0 {
  %3 = load i32, i32* %1, align 4, !tbaa !5
  %4 = getelementptr inbounds i32, i32* %1, i32 1
  %5 = load i32, i32* %4, align 4, !tbaa !5
  %6 = icmp slt i32 %3, %5
  %7 = select i1 %6, i32 %3, i32 %5
  store i32 %7, i32* %0, align 4, !tbaa !5
  %8 = load i32, i32* %4, align 4
  %9 = load i32, i32* %1, align 4
  %10 = select i1 %6, i32 %8, i32 %9
  %11 = getelementptr inbounds i32, i32* %0, i32 1
  store i32 %10, i32* %11, align 4
  store i32 %10, i32* %4, align 4, !tbaa !5
  %12 = getelementptr inbounds i32, i32* %1, i32 2
  %13 = load i32, i32* %12, align 4, !tbaa !5
  %14 = icmp slt i32 %10, %13
  %15 = select i1 %14, i32 %10, i32 %13
  store i32 %15, i32* %11, align 4, !tbaa !5
  %16 = load i32, i32* %12, align 4
  %17 = load i32, i32* %4, align 4
  %18 = select i1 %14, i32 %16, i32 %17
  %19 = getelementptr inbounds i32, i32* %0, i32 2
  store i32 %18, i32* %19, align 4
  %20 = load i32, i32* %0, align 4, !tbaa !5
  store i32 %20, i32* %1, align 4, !tbaa !5
  %21 = load i32, i32* %11, align 4, !tbaa !5
  store i32 %21, i32* %4, align 4, !tbaa !5
  %22 = icmp slt i32 %20, %21
  %23 = select i1 %22, i32 %20, i32 %21
  store i32 %23, i32* %0, align 4, !tbaa !5
  %24 = load i32, i32* %4, align 4
  %25 = load i32, i32* %1, align 4
  %26 = select i1 %22, i32 %24, i32 %25
  store i32 %26, i32* %11, align 4
  ret void
}

attributes #0 = { nofree norecurse nounwind sspstrong "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="i386" "target-features"="+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"NumRegisterParameters", i32 0}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{i32 7, !"PIE Level", i32 2}
!4 = !{!"clang version 10.0.1 "}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
