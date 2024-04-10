//  mlir-opt -pass-pipeline="builtin.module(func.func(convert-arith-to-llvm))" %s -split-input-file

func.func @main() -> () {
    %1 = arith.constant 1.0e1 : f32
    %2 = arith.constant 2.0e2 : f32
    %3 = call @arith_func(%1, %2) : (f32, f32) -> (f32)
    return
}

func.func @arith_func(%arg0: f32, %arg1: f32) -> (f32) {
    %1 = arith.mulf %arg0, %arg1 {approx = "exp"}: f32 // this lowered
    %2 = arith.addf %arg0, %1 : f32 // this is not lowered to intrinsic
    return %2: f32
}