//-----------------------------------------------
// OpenSCAD model by Kostas, ChatGPT 5, Gemini, and others
//


use <normal_utulities.scad>;

// Parameters
//-----------------------------------------------
// actual kalupi:
// sides rise angle = 72
// ratio of side flat to total height 0.42

// width to height ratio 1.48
// here: 125mm/85mm = 1.47

// length to width = 1.89 to 1.85
// here: 205mm/125mm = 1.64

$fn = 80;
samples = $fn;


stem_cut_height = 205; // FINAL HEIGHT

h = stem_cut_height + 5;  // CURVE MODELLING HEIGHT
w_actual = 115;
bulge_actual = 0.3; 
// BEST EXAMPLES HAVE THE WIDEST POINT AT 1/3 OF HEIGHT TO THE NECK

w_bottom = w_actual * 0.66; // empirical
bulge = bulge_actual * 1.66; // empirical
w_top = 13   -  (h-stem_cut_height)*0.8;
h_top = 18   -  (h-stem_cut_height)*0.9;

sides_angle_actual = 76;
sides_angle = sides_angle_actual * 1.09; // empirical
lift_angle=4;



function bezier_point(t, p0, p1, p2, p3) =
    pow(1-t,3)*p0 +
    3*pow(1-t,2)*t*p1 +
    3*(1-t)*pow(t,2)*p2 +
    pow(t,3)*p3;

function bezier_curve(p0, p1, p2, p3, n) =
    [ for (i = [0:(n)]) bezier_point(i/n, p0, p1, p2, p3) ];
    
p0 = [0,        0];
p1 = [w_bottom*sin(sides_angle)*1.12, h*0.03];
p2 = [w_bottom*sin(sides_angle)*0.91, h*bulge]; 
p3 = [h_top*0.35*sin(sides_angle),    h];
profile    = bezier_curve(p0, p1,  p2, p3, samples);

p1s = [w_bottom*1.26, 0];
p2s = [w_bottom*0.92, h*bulge]; 
p3s = [w_top,    h];
soundboard = bezier_curve(p0, p1s, p2s, p3s,  samples);

// 1. The original rotational body (stops at 80 degrees)
module pear_body(angle) {
    rotate_extrude(angle=90, start=0)
        polygon(profile);
    #rotate_extrude(angle=1, start=sides_angle_actual, $fn = 1)
        #polygon(profile);
}


module pear_with_extension(sides_angle)
{
        translate([0.35*h_top+stem_cut_height*(sin(lift_angle)),
                    0,
                    stem_cut_height*(sin(lift_angle)*sin(lift_angle) + 0.014)])
        rotate([0,-lift_angle,0])
                pear_body(sides_angle); 

        rotate([0, 0, 90]) rotate([90, 0, 0])
        linear_extrude(height=0.1)
            polygon(soundboard);
}

module baglama_round_top(sides_angle)
{
    intersection() {
        hull()
        {

        //union()
        //{
            // Positive Side
            pear_with_extension(sides_angle);
            // Negative Side (Mirrored)
            mirror([0,1,0]) pear_with_extension(sides_angle);
        //}
        }
        // Remove portion above horizontal plane (Stem cut)
        plane_zcut(stem_cut_height);
        soundboard_trimmer();
    }
}

module plane_zcut(zcut) {
    // Horizontal slice at z=zcut
    s=zcut;
    cube ( [2*s, 2*s,2*s], center=true);
}

// Helper: Defines the soundboard plane (The flat face of the instrument)
module soundboard_trimmer() {
    // A large cube positioned to cut everything "behind" the flat face
    // We position it at Y=0 (the center line)
    translate([ 0, -250, -250]) 
        cube([500, 500, 500]);
}

//module slice_at_z(z_pos, thickness=-1) {
//             
//    // 2. Intersect the cutter with every child module/geometry placed inside slice_at_z
//    intersection() {
//        translate([0, 0, z_pos])
//             cube([500, 500, thickness], center = true);
//        children(); // This is the key: it applies the cutter to the child geometry
//    }
//}

//projection(cut = false)
//slice_at_z(-1, thickness=1) 
//rotate([90,90,0])
scale([1.1,1,1])
baglama_round_top(sides_angle);
