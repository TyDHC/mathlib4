/-
Copyright (c) 2019 Kim Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison, Minchao Wu
-/
import Mathlib.Data.Prod.Basic
import Mathlib.Order.Lattice
import Mathlib.Order.BoundedOrder.Basic
import Mathlib.Tactic.Tauto

/-!
# Lexicographic order

This file defines the lexicographic relation for pairs of orders, partial orders and linear orders.

## Main declarations

* `Prod.Lex.<pre/partial/linear>Order`: Instances lifting the orders on `α` and `β` to `α ×ₗ β`.

## Notation

* `α ×ₗ β`: `α × β` equipped with the lexicographic order

## See also

Related files are:
* `Data.Finset.CoLex`: Colexicographic order on finite sets.
* `Data.List.Lex`: Lexicographic order on lists.
* `Data.Pi.Lex`: Lexicographic order on `Πₗ i, α i`.
* `Data.PSigma.Order`: Lexicographic order on `Σ' i, α i`.
* `Data.Sigma.Order`: Lexicographic order on `Σ i, α i`.
-/


variable {α β : Type*}

namespace Prod.Lex

open Batteries

@[inherit_doc] notation:35 α " ×ₗ " β:34 => Lex (Prod α β)

/-- Dictionary / lexicographic ordering on pairs. -/
instance instLE (α β : Type*) [LT α] [LE β] : LE (α ×ₗ β) where le := Prod.Lex (· < ·) (· ≤ ·)

instance instLT (α β : Type*) [LT α] [LT β] : LT (α ×ₗ β) where lt := Prod.Lex (· < ·) (· < ·)

theorem toLex_le_toLex [LT α] [LE β] {x y : α × β} :
    toLex x ≤ toLex y ↔ x.1 < y.1 ∨ x.1 = y.1 ∧ x.2 ≤ y.2 :=
  Prod.lex_def

theorem toLex_lt_toLex [LT α] [LT β] {x y : α × β} :
    toLex x < toLex y ↔ x.1 < y.1 ∨ x.1 = y.1 ∧ x.2 < y.2 :=
  Prod.lex_def

lemma le_iff [LT α] [LE β] {x y : α ×ₗ β} :
    x ≤ y ↔ (ofLex x).1 < (ofLex y).1 ∨ (ofLex x).1 = (ofLex y).1 ∧ (ofLex x).2 ≤ (ofLex y).2 :=
  Prod.lex_def

lemma lt_iff [LT α] [LT β] {x y : α ×ₗ β} :
    x < y ↔ (ofLex x).1 < (ofLex y).1 ∨ (ofLex x).1 = (ofLex y).1 ∧ (ofLex x).2 < (ofLex y).2 :=
  Prod.lex_def

instance [LT α] [LT β] [WellFoundedLT α] [WellFoundedLT β] : WellFoundedLT (α ×ₗ β) :=
  instIsWellFounded

instance [LT α] [LT β] [WellFoundedLT α] [WellFoundedLT β] : WellFoundedRelation (α ×ₗ β) :=
  ⟨(· < ·), wellFounded_lt⟩

/-- Dictionary / lexicographic preorder for pairs. -/
instance preorder (α β : Type*) [Preorder α] [Preorder β] : Preorder (α ×ₗ β) :=
  { Prod.Lex.instLE α β, Prod.Lex.instLT α β with
    le_refl := refl_of <| Prod.Lex _ _,
    le_trans := fun _ _ _ => trans_of <| Prod.Lex _ _,
    lt_iff_le_not_le := fun x₁ x₂ =>
      match x₁, x₂ with
      | (a₁, b₁), (a₂, b₂) => by
        constructor
        · rintro (⟨_, _, hlt⟩ | ⟨_, hlt⟩)
          · constructor
            · exact left _ _ hlt
            · rintro ⟨⟩
              · apply lt_asymm hlt; assumption
              · exact lt_irrefl _ hlt
          · constructor
            · right
              rw [lt_iff_le_not_le] at hlt
              exact hlt.1
            · rintro ⟨⟩
              · apply lt_irrefl a₁
                assumption
              · rw [lt_iff_le_not_le] at hlt
                apply hlt.2
                assumption
        · rintro ⟨⟨⟩, h₂r⟩
          · left
            assumption
          · right
            rw [lt_iff_le_not_le]
            constructor
            · assumption
            · intro h
              apply h₂r
              right
              exact h }

theorem monotone_fst [Preorder α] [LE β] (t c : α ×ₗ β) (h : t ≤ c) :
    (ofLex t).1 ≤ (ofLex c).1 := by
  cases toLex_le_toLex.mp h with
  | inl h' => exact h'.le
  | inr h' => exact h'.1.le

section Preorder

variable [PartialOrder α] [Preorder β] {x y : α × β}

/-- Variant of `Prod.Lex.toLex_le_toLex` for partial orders. -/
lemma toLex_le_toLex' : toLex x ≤ toLex y ↔ x.1 ≤ y.1 ∧ (x.1 = y.1 → x.2 ≤ y.2) := by
  simp only [toLex_le_toLex, lt_iff_le_not_le, le_antisymm_iff]
  tauto

/-- Variant of `Prod.Lex.toLex_lt_toLex` for partial orders. -/
lemma toLex_lt_toLex' : toLex x < toLex y ↔ x.1 ≤ y.1 ∧ (x.1 = y.1 → x.2 < y.2) := by
  rw [toLex_lt_toLex]
  simp only [lt_iff_le_not_le, le_antisymm_iff]
  tauto

/-- Variant of `Prod.Lex.le_iff` for partial orders. -/
lemma le_iff' {x y : α ×ₗ β} :
    x ≤ y ↔ (ofLex x).1 ≤ (ofLex y).1 ∧ ((ofLex x).1 = (ofLex y).1 → (ofLex x).2 ≤ (ofLex y).2) :=
  toLex_le_toLex'

/-- Variant of `Prod.Lex.lt_iff` for partial orders. -/
lemma lt_iff' {x y : α ×ₗ β} :
    x < y ↔ (ofLex x).1 ≤ (ofLex y).1 ∧ ((ofLex x).1 = (ofLex y).1 → (ofLex x).2 < (ofLex y).2) :=
  toLex_lt_toLex'

theorem toLex_mono : Monotone (toLex : α × β → α ×ₗ β) :=
  fun _x _y hxy ↦ toLex_le_toLex'.2 ⟨hxy.1, fun _ ↦ hxy.2⟩

theorem toLex_strictMono : StrictMono (toLex : α × β → α ×ₗ β) := by
  rintro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩ h
  obtain rfl | ha : a₁ = a₂ ∨ _ := h.le.1.eq_or_lt
  · exact right _ (Prod.mk_lt_mk_iff_right.1 h)
  · exact left _ _ ha

end Preorder

/-- Dictionary / lexicographic partial order for pairs. -/
instance partialOrder (α β : Type*) [PartialOrder α] [PartialOrder β] : PartialOrder (α ×ₗ β) where
  le_antisymm _ _ := by
    haveI : IsStrictOrder α (· < ·) := { irrefl := lt_irrefl, trans := fun _ _ _ => lt_trans }
    haveI : IsAntisymm β (· ≤ ·) := ⟨fun _ _ => le_antisymm⟩
    exact antisymm (r := Prod.Lex _ _)

instance instOrdLexProd [Ord α] [Ord β] : Ord (α ×ₗ β) := lexOrd

theorem compare_def [Ord α] [Ord β] : @compare (α ×ₗ β) _ =
    compareLex (compareOn fun x => (ofLex x).1) (compareOn fun x => (ofLex x).2) := rfl

theorem _root_.lexOrd_eq [Ord α] [Ord β] : @lexOrd α β _ _ = instOrdLexProd := rfl

theorem _root_.Ord.lex_eq [oα : Ord α] [oβ : Ord β] : Ord.lex oα oβ = instOrdLexProd := rfl

instance [Ord α] [Ord β] [OrientedOrd α] [OrientedOrd β] : OrientedOrd (α ×ₗ β) :=
  inferInstanceAs (OrientedCmp (compareLex _ _))

instance [Ord α] [Ord β] [TransOrd α] [TransOrd β] : TransOrd (α ×ₗ β) :=
  inferInstanceAs (TransCmp (compareLex _ _))

/-- Dictionary / lexicographic linear order for pairs. -/
instance linearOrder (α β : Type*) [LinearOrder α] [LinearOrder β] : LinearOrder (α ×ₗ β) :=
  { Prod.Lex.partialOrder α β with
    le_total := total_of (Prod.Lex _ _)
    toDecidableLE := Prod.Lex.decidable _ _
    toDecidableLT := Prod.Lex.decidable _ _
    toDecidableEq := instDecidableEqLex _
    compare_eq_compareOfLessAndEq := fun a b => by
      have : DecidableLT (α ×ₗ β) := Prod.Lex.decidable _ _
      have : BEqOrd (α ×ₗ β) := ⟨by
        simp [compare_def, compareLex, compareOn, Ordering.then_eq_eq, compare_eq_iff_eq]⟩
      have : LTOrd (α ×ₗ β) := ⟨by
        simp [compare_def, compareLex, compareOn, Ordering.then_eq_lt, toLex_lt_toLex,
          compare_lt_iff_lt, compare_eq_iff_eq]⟩
      convert LTCmp.eq_compareOfLessAndEq (cmp := compare) a b }

instance orderBot [PartialOrder α] [Preorder β] [OrderBot α] [OrderBot β] : OrderBot (α ×ₗ β) where
  bot := toLex ⊥
  bot_le _ := toLex_mono bot_le

instance orderTop [PartialOrder α] [Preorder β] [OrderTop α] [OrderTop β] : OrderTop (α ×ₗ β) where
  top := toLex ⊤
  le_top _ := toLex_mono le_top

instance boundedOrder [PartialOrder α] [Preorder β] [BoundedOrder α] [BoundedOrder β] :
    BoundedOrder (α ×ₗ β) :=
  { Lex.orderBot, Lex.orderTop with }

instance [Preorder α] [Preorder β] [DenselyOrdered α] [DenselyOrdered β] :
    DenselyOrdered (α ×ₗ β) where
  dense := by
    rintro _ _ (@⟨a₁, b₁, a₂, b₂, h⟩ | @⟨a, b₁, b₂, h⟩)
    · obtain ⟨c, h₁, h₂⟩ := exists_between h
      exact ⟨(c, b₁), left _ _ h₁, left _ _ h₂⟩
    · obtain ⟨c, h₁, h₂⟩ := exists_between h
      exact ⟨(a, c), right _ h₁, right _ h₂⟩

instance noMaxOrder_of_left [Preorder α] [Preorder β] [NoMaxOrder α] : NoMaxOrder (α ×ₗ β) where
  exists_gt := by
    rintro ⟨a, b⟩
    obtain ⟨c, h⟩ := exists_gt a
    exact ⟨⟨c, b⟩, left _ _ h⟩

instance noMinOrder_of_left [Preorder α] [Preorder β] [NoMinOrder α] : NoMinOrder (α ×ₗ β) where
  exists_lt := by
    rintro ⟨a, b⟩
    obtain ⟨c, h⟩ := exists_lt a
    exact ⟨⟨c, b⟩, left _ _ h⟩

instance noMaxOrder_of_right [Preorder α] [Preorder β] [NoMaxOrder β] : NoMaxOrder (α ×ₗ β) where
  exists_gt := by
    rintro ⟨a, b⟩
    obtain ⟨c, h⟩ := exists_gt b
    exact ⟨⟨a, c⟩, right _ h⟩

instance noMinOrder_of_right [Preorder α] [Preorder β] [NoMinOrder β] : NoMinOrder (α ×ₗ β) where
  exists_lt := by
    rintro ⟨a, b⟩
    obtain ⟨c, h⟩ := exists_lt b
    exact ⟨⟨a, c⟩, right _ h⟩

end Prod.Lex
