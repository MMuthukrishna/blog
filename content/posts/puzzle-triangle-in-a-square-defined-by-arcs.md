+++
title = "Puzzle: Triangle in a Square Defined by Arcs"
slug = "puzzle-triangle-in-a-square-defined-by-arcs"
author = "M.Muthukrishna"
date = 2020-12-08T20:22:45+05:30
categories = ["math"]
tags = ["puzzle"]
markup = "mmark"
katex = true
draft = false
+++

### [Question](https://www.youtube.com/watch?v=ah2Ss6ogb44)

![question](/image/puzzle-triangle-in-a-square-defined-by-arcs/question.png)

### Solving it using GeoGebra

![answer](/image/puzzle-triangle-in-a-square-defined-by-arcs/geogebra.png)

Area of the triange is $$0.04 x^2$$ where $$x$$ is the length of the side of the square.

### Solving it without GeoGebra

Let the Quarter Circle ACD be $$C_1$$  
Let the Semi Circle with Diameter along AB be $$C_2$$  
Let the Semi Circle with Diameter along BC be $$C_3$$

$$ C_1: x^2 + y^2 = 1 $$  
$$ C_2: (x-0.5)^2 + (y-1)^2 = 0.25 $$  
$$ C_3: (x-1)^2 + (y-0.5)^2 = 0.25 $$  

To Find $$C_1$$ intersection $$C_2$$

$$1: x^2 + y^2 = 1 $$  
$$2: x^2 + 0.25 - x + y^2 + 1 - 2y = 0.25 $$  

$$1-2: x + 2y - 1.25 = 0.75 $$  
$$1-2: x + 2y = 2 $$  

$$ L_1: x + 2y = 2 $$ is a line passing through A and G

Substituting $$ L_1 $$ in $$C_1$$ to find A and G

$$ 4 + 4y^2 - 8y + y^2 = 1 $$  
$$ 5y^2 - 8y + 3 = 0 $$  
$$ 5y^2 - 5y - 3y + 3 = 0 $$    
$$ 5y(y-1) - 3(y-1) = 0 $$
$$ (5y-3)(y-1) = 0 $$

$$ A: (0, 1) $$  
$$ G: (0.8, 0.6) $$

To Find $$C_1$$ intersection $$C_3$$

$$ 3: x^2 + y^2 = 1 $$  
$$ 4: x^2 + 1 - 2x + y^2 + 0.25 - y = 0.25 $$  

$$ 3-4: 2x + y - 1.25 = 0.75 $$  
$$ 3-4: 2x + y = 2 $$

$$ L_2: 2x + y = 2 $$ is a line passing through F and C

Finding C and F by substituting $$L_2$$ in $$C_1$$

$$ C: (1, 0) $$  
$$ F: (0.6, 0.8) $$  

To Find $$C_2$$ intersection $$C_3$$

$$ 5: x^2 + 0.25 - x + y^2 + 1 - 2y = 0.25  $$  
$$ 6: x^2 + 1 - 2x + y^2 + 0.25 - y = 0.25 = 0.25 $$  
$$ 5-6: x - y = 0 $$  

$$ L_3: x - y = 0 $$ is a line passing through E and B

Finding B and E by substituting $$L_3$$ in $$C_3$$ 

$$ B: (0, 0) $$  
$$ E: (0.5, 0.5) $$

The triangle in the shaded region is EFG, where EF = EG

Base of EFG is FG = sqrt(0.08)  
Height of EFG is = sqrt(0.08)

Area of EFG is 0.5 * base * height which is 0.04
