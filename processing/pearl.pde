/**
 * This class is used for the roller effect,
 * where coloured balls come from the top to
 * mimick what happens in the physical roller.
 *
 * The logic for drawing was taken from this example
 * <http://solemone.de/demos/snow-effect-processing/>
 * and I have adapted it to be in a class (to separate variables)
 * and different settings for the sketch and have multiple colours
 */

class Pearl {
	private float x;
	private float y;
	private int radius;
	private int direction;
	private color colour;


	// Constructor - generate random parameters
	// for every 'pearl' coming down
	Pearl()
	{
		this.x = random(xShift, width);
		this.y = random(yShift, height);
		this.radius = round(random(2, 8));
		this.direction = round(random(0, 1));

		// use any of 3 colours (red, green, yellow)
		int rand = round(random(0, 2));
		if(rand == 0) this.colour = red;
		else if(rand == 1) this.colour = green;
		else if(rand == 2) this.colour = yellow;
	}

	// again this one effect was taken from
	// http://solemone.de/demos/snow-effect-processing/
	public void draw()
	{
		fill(this.colour, effects[PEARLS].timer(0, 255));
		ellipse(this.x + xShift, this.y, this.radius, this.radius);

		if(this.direction == 0) {
		  this.x += map(this.radius, 2, 8, .1, .5);
		} else {
		  this.x -= map(this.radius, 2, 8, .1, .5);
		}

		this.y += this.radius + this.direction;

		if(this.x > width + this.radius || this.x < -this.radius || this.y > height + this.radius) {
		  this.x = random(xShift, width);
		  this.y = yShift - this.radius;
		}
	}
}