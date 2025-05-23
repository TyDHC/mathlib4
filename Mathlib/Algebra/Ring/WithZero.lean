/-
Copyright (c) 2020 Mario Carneiro, Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johan Commelin
-/
import Mathlib.Algebra.GroupWithZero.WithZero
import Mathlib.Algebra.Ring.Defs

/-!
# Adjoining a zero to a semiring
-/

namespace WithZero
variable {α : Type*}

instance instLeftDistribClass [Mul α] [Add α] [LeftDistribClass α] :
    LeftDistribClass (WithZero α) where
  left_distrib a b c := by
    cases a; · rfl
    cases b <;> cases c <;> try rfl
    exact congr_arg some (left_distrib _ _ _)

instance instRightDistribClass [Mul α] [Add α] [RightDistribClass α] :
    RightDistribClass (WithZero α) where
  right_distrib a b c := by
    cases c; · simp
    cases a <;> cases b <;> try rfl
    exact congr_arg some (right_distrib _ _ _)

instance instDistrib [Distrib α] : Distrib (WithZero α) where
  left_distrib := left_distrib
  right_distrib := right_distrib

instance instSemiring [Semiring α] : Semiring (WithZero α) where

end WithZero
