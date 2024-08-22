import Lake
open Lake DSL

package «solutions» where
  -- add package configuration options here

@[default_target]
lean_lib «Solutions» where
  -- add library configuration options here
  globs := #[.submodules `Solutions]
