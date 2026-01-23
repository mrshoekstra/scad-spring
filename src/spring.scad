// Height in millimeters
height = 2; // [1:0.5:20]
// Number of steps
steps = 15; // [2:1:100]
// Gap size between steps in millimeters
gap = 3.75; // [1:0.25:20]
// Make the start and end of the spring rounded
tips = true;
// Spring line thickness
thickness = 1.75; // [0.5:0.25:20]
// Spring width in millimeters
width = 16; // [4:1:60]

minWidth = gap * 2 + thickness * 3;

assert(
	width >= minWidth,
	str("Width \"", width, "\" is too small for the current \"gap\" and \"thickness\" settings. Width must be at least \"", minWidth, "\" (gap x 2 + thickness x 3)")
);


stepSize = gap + thickness;
arch = gap + thickness * 2;

spring();

module spring()
{
	$fn = 128;

	if (tips)
	{
		translate([(width - arch) * -0.5, 0])
			tip();
		translate([(width - arch) * (steps % 2 ? 0.5 : -0.5), stepSize * (steps - 1)])
			tip();
	}

	maxCount = steps / 2 - 1;

	for (step = [0 : maxCount])
	{
		translate([0, step * 2 * stepSize])
			part();

		if (step < maxCount)
		{
			translate([0, (step + 0.5) * 2 * stepSize])
				rotate([0, 180, 0])
					part();
		}
	}

	translate([0, (steps / 2 - 0.5) * 2 * stepSize])
		line();
}

module part()
{
	line();
	arch();
}

module arch()
{
	centerOffset = (width - arch) / 2;
	lineSize = stepSize / 2;

	difference()
	{
		translate([centerOffset, lineSize])
			cylinder(height, d=arch, center=true);
		translate([centerOffset, lineSize])
			cylinder(height, d=arch-thickness*2, center=true);
		translate([0, lineSize])
			cube([width - arch, gap, height], center=true);
	}
}

module line()
{
	cube([width - arch, thickness, height], center=true);
}

module tip()
{
	cylinder(height, d=thickness, center=true);
}
