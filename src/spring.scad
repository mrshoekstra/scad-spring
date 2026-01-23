/* [Preview] */
// Preview in lower resolution (always renders in high resolution)
Preview_resolution = 16; // [8, 16, 32, 64, 128]

/* [Spring] */
// Spring height / Z-axis (millimeters)
Spring_height = 2; // [1:0.1:20]
// Spring line thickness (millimeters)
Spring_thickness = 1.75; // [0.5:0.25:20]
// Spring width / X-axis (millimeters)
Spring_width = 16; // [4:1:60]


/* [Steps] */
// Number of ladder steps / horizontal lines
Steps_count = 15; // [2:1:100]
// Gap size between steps (millimeters)
Steps_gap = 3.75; // [1:0.25:20]

/* [Ends] */
// Make the start and end tips of the spring rounded
Ends_rounded = true;

/* [Hidden] */
$fn = $preview ? Preview_resolution : 128;
springHeight = Spring_height;
springThickness = Spring_thickness;
springWidth = Spring_width;
stepsCount = Steps_count;
stepsGap = Steps_gap;
endsRounded = Ends_rounded;

minWidth = stepsGap * 2 + springThickness * 3;

assert(
	springWidth >= minWidth,
	str("Width \"", springWidth, "\" is too small for the current Gap and Thickness settings. Width must be at least: \"", minWidth, "\" (Gap x 2 + Thickness x 3)")
);

partPosition = stepsGap + springThickness;
archOuterDiameter = stepsGap + springThickness * 2;

spring();

module spring()
{
	if (endsRounded)
	{
		translate([(springWidth - archOuterDiameter) * -0.5, 0])
			tip();
		translate([(springWidth - archOuterDiameter) * (stepsCount % 2 ? 0.5 : -0.5), partPosition * (stepsCount - 1)])
			tip();
	}

	maxCount = stepsCount / 2 - 1;

	for (step = [0 : maxCount])
	{
		translate([0, step * 2 * partPosition])
			part();

		if (step < maxCount)
		{
			translate([0, (step + 0.5) * 2 * partPosition])
				rotate([0, 180, 0])
					part();
		}
	}

	translate([0, (stepsCount / 2 - 0.5) * 2 * partPosition])
		line();
}

module part()
{
	line();
	arch();
}

module arch()
{
	centerOffsetX = (springWidth - archOuterDiameter) / 2;
	centerOffsetY = partPosition / 2;
	archInnerDiameter = archOuterDiameter - springThickness * 2;

	difference()
	{
		translate([centerOffsetX, centerOffsetY])
			cylinder(springHeight, d=archOuterDiameter, center=true);
		translate([centerOffsetX, centerOffsetY])
			cylinder(springHeight, d=archInnerDiameter, center=true);
		translate([0, centerOffsetY])
			cube([springWidth - archOuterDiameter, stepsGap, springHeight], center=true);
	}
}

module line()
{
	lineWidth = springWidth - archOuterDiameter;
	cube([lineWidth, springThickness, springHeight], center=true);
}

module tip()
{
	cylinder(springHeight, d=springThickness, center=true);
}
