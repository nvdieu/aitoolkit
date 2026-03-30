# 🤖 AIToolkit: A Logic & Search Library for Prolog

**AIToolkit** is a high-performance, educational Prolog library (`aitool.pl`) designed to simplify the implementation of Artificial Intelligence concepts. It provides built-in support for Propositional Logic, Constraint Satisfaction Problems (CSP), and State-Space Search algorithms.

Developed for the **Artificial Intelligence Course (2026)**, this toolkit allows students and researchers to focus on modeling problems rather than low-level algorithmic implementation.

---

## 🌟 Key Features

### 1. Logic Engine
- **Automated CNF Conversion**: Transform any logic expression into Conjunctive Normal Form.
- **Resolution Proof**: Prove logical entailments using the refutation method (contradiction).
- **Truth Table Generator**: Visualize the truth values of complex propositions.
- **Custom Operators**: Native support for `neg`, `and`, `or`, and `imp`.

### 2. CSP Solver
- **Generic Backtracking**: Solve puzzles like "The Lady or the Tiger" or "N-Queens" with ease.
- **Predicate-based Constraints**: Define your rules in standard Prolog and let the solver find the valid configurations.

### 3. State-Space Search
- **Standard Algorithms**: Pre-implemented A*, Best-First Search, BFS, and DFS.
- **Cycle Detection**: Built-in path tracking to prevent infinite loops in graph traversal.

---

## 📦 Getting Started

### Prerequisites
- [SWI-Prolog](https://www.swi-prolog.org/) (Version 9.x or higher recommended).

### Installation
Clone this repository to your local machine:
- [https://github.com/nvdieu/aitoolkit.git](https://github.com/nvdieu/aitoolkit)
