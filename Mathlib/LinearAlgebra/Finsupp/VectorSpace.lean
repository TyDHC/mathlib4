/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl
-/
import Mathlib.LinearAlgebra.Basis.Defs
import Mathlib.LinearAlgebra.DFinsupp
import Mathlib.LinearAlgebra.Finsupp.Span
import Mathlib.LinearAlgebra.FreeModule.Basic

/-!
# Linear structures on function with finite support `ι →₀ M`

This file contains results on the `R`-module structure on functions of finite support from a type
`ι` to an `R`-module `M`, in particular in the case that `R` is a field.

-/


noncomputable section

open Set LinearMap Submodule

universe u v w

namespace Finsupp

section Ring

variable {R : Type*} {M : Type*} {ι : Type*}
variable [Ring R] [AddCommGroup M] [Module R M]

theorem linearIndependent_single {φ : ι → Type*} {f : ∀ ι, φ ι → M}
    (hf : ∀ i, LinearIndependent R (f i)) :
    LinearIndependent R fun ix : Σi, φ i => single ix.1 (f ix.1 ix.2) := by
  apply @linearIndependent_iUnion_finite R _ _ _ _ ι φ fun i x => single i (f i x)
  · intro i
    have h_disjoint : Disjoint (span R (range (f i))) (ker (lsingle i)) := by
      rw [ker_lsingle]
      exact disjoint_bot_right
    apply (hf i).map h_disjoint
  · intro i t _ hit
    refine (disjoint_lsingle_lsingle {i} t (disjoint_singleton_left.2 hit)).mono ?_ ?_
    · rw [span_le]
      simp only [iSup_singleton]
      rw [range_coe]
      apply range_comp_subset_range _ (lsingle i)
    · refine iSup₂_mono fun i hi => ?_
      rw [span_le, range_coe]
      apply range_comp_subset_range _ (lsingle i)

end Ring

section Semiring

variable {R : Type*} {M : Type*} {ι : Type*}
variable [Semiring R] [AddCommMonoid M] [Module R M]

open LinearMap Submodule

open scoped Classical in
/-- The basis on `ι →₀ M` with basis vectors `fun ⟨i, x⟩ ↦ single i (b i x)`. -/
protected def basis {φ : ι → Type*} (b : ∀ i, Basis (φ i) R M) : Basis (Σi, φ i) R (ι →₀ M) :=
  Basis.ofRepr
    { toFun := fun g =>
        { toFun := fun ix => (b ix.1).repr (g ix.1) ix.2
          support := g.support.sigma fun i => ((b i).repr (g i)).support
          mem_support_toFun := fun ix => by
            simp only [Finset.mem_sigma, mem_support_iff, and_iff_right_iff_imp, Ne]
            intro b hg
            simp [hg] at b }
      invFun := fun g =>
        { toFun := fun i => (b i).repr.symm (g.comapDomain _ sigma_mk_injective.injOn)
          support := g.support.image Sigma.fst
          mem_support_toFun := fun i => by
            rw [Ne, ← (b i).repr.injective.eq_iff, (b i).repr.apply_symm_apply,
                DFunLike.ext_iff]
            simp only [exists_prop, LinearEquiv.map_zero, comapDomain_apply, zero_apply,
              exists_and_right, mem_support_iff, exists_eq_right, Sigma.exists, Finset.mem_image,
              not_forall] }
      left_inv := fun g => by
        ext i
        rw [← (b i).repr.injective.eq_iff]
        ext x
        simp only [coe_mk, LinearEquiv.apply_symm_apply, comapDomain_apply]
      right_inv := fun g => by
        ext ⟨i, x⟩
        simp only [coe_mk, LinearEquiv.apply_symm_apply, comapDomain_apply]
      map_add' := fun g h => by
        ext ⟨i, x⟩
        simp only [coe_mk, add_apply, LinearEquiv.map_add]
      map_smul' := fun c h => by
        ext ⟨i, x⟩
        simp only [coe_mk, smul_apply, LinearEquiv.map_smul, RingHom.id_apply] }

@[simp]
theorem basis_repr {φ : ι → Type*} (b : ∀ i, Basis (φ i) R M) (g : ι →₀ M) (ix) :
    (Finsupp.basis b).repr g ix = (b ix.1).repr (g ix.1) ix.2 :=
  rfl

@[simp]
theorem coe_basis {φ : ι → Type*} (b : ∀ i, Basis (φ i) R M) :
    ⇑(Finsupp.basis b) = fun ix : Σi, φ i => single ix.1 (b ix.1 ix.2) :=
  funext fun ⟨i, x⟩ =>
    Basis.apply_eq_iff.mpr <| by
      classical
      ext ⟨j, y⟩
      by_cases h : i = j
      · cases h
        simp [Finsupp.single_apply_left sigma_mk_injective]
      · simp_all

variable (ι R M) in
instance _root_.Module.Free.finsupp [Module.Free R M] : Module.Free R (ι →₀ M) :=
  .of_basis (Finsupp.basis fun _ => Module.Free.chooseBasis R M)

/-- The basis on `ι →₀ R` with basis vectors `fun i ↦ single i 1`. -/
@[simps]
protected def basisSingleOne : Basis ι R (ι →₀ R) :=
  Basis.ofRepr (LinearEquiv.refl _ _)

@[simp]
theorem coe_basisSingleOne : (Finsupp.basisSingleOne : ι → ι →₀ R) = fun i => Finsupp.single i 1 :=
  funext fun _ => Basis.apply_eq_iff.mpr rfl

end Semiring

end Finsupp

namespace DFinsupp
variable {ι : Type*} {R : Type*} {M : ι → Type*}
variable [Semiring R] [∀ i, AddCommMonoid (M i)] [∀ i, Module R (M i)]

/-- The direct sum of free modules is free.

Note that while this is stated for `DFinsupp` not `DirectSum`, the types are defeq. -/
noncomputable def basis {η : ι → Type*} (b : ∀ i, Basis (η i) R (M i)) :
    Basis (Σi, η i) R (Π₀ i, M i) :=
  .ofRepr
    ((mapRange.linearEquiv fun i => (b i).repr).trans (sigmaFinsuppLequivDFinsupp R).symm)

variable (R M) in
instance _root_.Module.Free.dfinsupp [∀ i : ι, Module.Free R (M i)] : Module.Free R (Π₀ i, M i) :=
  .of_basis <| DFinsupp.basis fun i => Module.Free.chooseBasis R (M i)

end DFinsupp

lemma Module.Free.trans {R S M : Type*} [CommSemiring R] [Semiring S] [Algebra R S]
    [AddCommMonoid M] [Module R M] [Module S M] [IsScalarTower R S M] [Module.Free S M]
    [Module.Free R S] : Module.Free R M :=
  let e : (ChooseBasisIndex S M →₀ S) ≃ₗ[R] ChooseBasisIndex S M →₀ (ChooseBasisIndex R S →₀ R) :=
    Finsupp.mapRange.linearEquiv (chooseBasis R S).repr
  let e : M ≃ₗ[R] ChooseBasisIndex S M →₀ (ChooseBasisIndex R S →₀ R) :=
    (chooseBasis S M).repr.restrictScalars R ≪≫ₗ e
  .of_equiv e.symm

/-! TODO: move this section to an earlier file. -/


namespace Basis

variable {R M n : Type*}
variable [DecidableEq n]
variable [Semiring R] [AddCommMonoid M] [Module R M]

theorem _root_.Finset.sum_single_ite [Fintype n] (a : R) (i : n) :
    (∑ x : n, Finsupp.single x (if i = x then a else 0)) = Finsupp.single i a := by
  simp only [apply_ite (Finsupp.single _), Finsupp.single_zero, Finset.sum_ite_eq,
    if_pos (Finset.mem_univ _)]

@[simp]
theorem equivFun_symm_single [Finite n] (b : Basis n R M) (i : n) :
    b.equivFun.symm (Pi.single i 1) = b i := by
  cases nonempty_fintype n
  simp [Pi.single_apply]

end Basis

section Algebra

variable {R S : Type*} [CommRing R] [Ring S] [Algebra R S] {ι : Type*} (B : Basis ι R S)

/-- For any `r : R`, `s : S`, we have
  `B.repr ((algebra_map R S r) * s) i = r * (B.repr s i) `. -/
theorem Basis.repr_smul'  (i : ι) (r : R) (s : S) :
    B.repr (algebraMap R S r * s) i = r * B.repr s i := by
  rw [← smul_eq_mul, ← smul_eq_mul, algebraMap_smul, map_smul, Finsupp.smul_apply]

end Algebra
