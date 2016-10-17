function flatten(l) = [ for (a = l) for (b = a) b ] ;
function in2ft(i) = i / 12;

module doorway(width, height, arch=false) {
  thickness = 3;
  translate([-width/2, -thickness/2, 0]) {
      cube([width, thickness, height]);
      if (arch) {
        translate([width/2, 0, height]) {
          rotate([-90, 0, 0]) {
            cylinder(thickness, d=width, $fs=.1);
          }
        }
      }
  }
}

module room(size, walls=[1, 1, 1]) {
     difference() {
          cube([for (i = [0:1:2]) size[i]+walls[i]]);
          translate([for (i = [0:1:2]) walls[i]/2]) {
               cube(size);
          }
     }
}

module room_cutout(size, walls=[1, 1, 1]) {
     cube([for (i = [0:1:2]) size[i]+walls[i]]);
}

module vestibule(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  door_height = in2ft(80);
  width = stair_dia + 2*door_width;
  length = 1.1*(stair_dia + 2*door_width);
  //echo(width+1, length+2);
  translate([-width/2, -length/2, 0]) {
    difference() {
      union() {
        // walls
        translate([-0.5, -1, 0]) {
          cube([width+1, length+2, height]);
        }
        // compartments
        translate([-3-0.5-in2ft(8), .25*length-.25-door_width/2-in2ft(4), 0.75]) {
          room([door_width+in2ft(8), door_width+in2ft(8), 7.5], [0.5, 0.5, 0.5]);
        }
        translate([width, .75*length-door_width/2+in2ft(4)-5, 0.75]) {
          room([6, 8, 7.5], [0.5, 0.5, 0.5]);
        }
      }
      // interior
      translate([0, 0, 1]) {
        cube([width, length, height]);
      }
      // end doors
      translate([width/2, 0, 1]) {
        doorway(in2ft(42), in2ft(80), arch=true);
      }
      translate([width/2, length, 1]) {
        doorway(in2ft(42), in2ft(80), arch=true);
      }
      // compartment doors
      translate([0, .25*length, 1]) {
        rotate([0, 0, 90]) {
          doorway(in2ft(36), in2ft(80));
        }
      }
      translate([width, .75*length, 1]) {
        rotate([0, 0, 90]) {
          doorway(in2ft(36), in2ft(80));
        }
      }
      // stairwell
      translate([width/2, length/2, -2]) {
        cylinder(height+5, d=stair_dia, $fs=.1, $fa=5);
      }
    }
  }
}

module vestibule_cutout(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  door_height = in2ft(80);
  width = stair_dia + 2*door_width;
  length = 1.1*(stair_dia + 2*door_width)+2;
  //echo(width+1, length+2);
  translate([-width/2, -length/2, 0]) {
    // walls
    translate([-0.5, -1, 1]) {
      cube([width+1, length+2, height+1]);
    }
    // compartments
    translate([-3-0.5-in2ft(8), .25*length-.25-door_width/2-in2ft(4), 0.75]) {
      room_cutout([door_width+in2ft(8), door_width+in2ft(8), 7.5], [0.5, 0.5, 0.5]);
    }
    translate([width, .75*length-door_width/2+in2ft(4)-5, 0.75]) {
      room_cutout([6, 8, 7.5], [0.5, 0.5, 0.5]);
    }
    // stairwell
    translate([width/2, length/2, -2]) {
      cylinder(height+4, d=stair_dia, $fs=.1, $fa=5);
    }
  }
}

module railing(height, inner_dia) {
  inner_radius = inner_dia/2;
  mid_radius = inner_radius + in2ft(1.5);
  outer_radius = inner_radius + in2ft(3);
  translate([0, 0, 3]) {
    difference() {
      cylinder(in2ft(1), d=outer_radius*2,
               $fs=.1, $fa=5);
      translate([0, 0, -0.5]) {
        cylinder(1, d=inner_radius*2, $fs=.1, $fa=5);
      }
    }
    for(a = [0:6:360]) {
      rotate([0, 0, a]) {
        translate([mid_radius, 0, -height]) {
          rotate([0, 0, 45]) {
            cylinder(3, d=in2ft(1), $fn=4);
          }
        }
      }
    }
  }
}

function gallery_radius(inner_radius, stair_dia=in2ft(48)) = ((inner_radius/(2*sqrt(3)/3))+((1.1*(stair_dia + 2*in2ft(36))+2)/2))*(2*sqrt(3)/3);

module gallery(center, inner_radius, height, stair_dia=in2ft(48), layout=[0, 1, 1, 0, 1, 1]) {
  door_width=in2ft(36);
  vestibule_width = stair_dia + 2*door_width;
  vestibule_length = 1.1*(stair_dia + 2*door_width)+2;
  thickness = vestibule_length/2;
  inner_apothem = inner_radius/(2*sqrt(3)/3);
  outer_apothem = inner_apothem+thickness;
  outer_radius = outer_apothem*(2*sqrt(3)/3);
  r = outer_apothem;
  translate(center) {
    difference() {
      // outer wall
      cylinder(height, d=outer_radius*2, $fn=6);
      // inner volume
      translate([0, 0, 1]) {
        cylinder(height, d=inner_radius*2, $fn=6);
      }
      // stairwells and vestibule cutouts
      for (s = [0:1:5]) {
        angle = 60*(s-2);
        translate([r*sin(angle), r*cos(angle), 0]) {
          if (layout[s]) {
            translate([0, 0, -2]) {
              cylinder(height+4, d=stair_dia, $fs=.1, $fa=5);
            }
          } else {
            rotate([0, 0, -angle]) {
              vestibule_cutout(height-1, stair_dia, door_width);
            }
          }
        }
      }
      // ventilation shaft
      translate([0, 0, -1]) {
        cylinder(3, d=inner_radius/sqrt(2), $fs=.1, $fa=5);
      }
    }
    // railing
    railing(3, inner_radius/sqrt(2));
    // vestibules
    for (s = [0:1:5]) {
      angle = 60*(s-2);
      translate([r*sin(angle), r*cos(angle), 0]) {
        if (!layout[s]) {
          rotate([0, 0, -angle]) {
            vestibule(height, stair_dia, door_width);
          }
        }
      }
    }
  }
}

stair_dia=in2ft(72);
hex_radius = gallery_radius(22, stair_dia);
hex_height = 11;
function hex2coord(q, r, z) = [ hex_radius * 3/2 * q, hex_radius * sqrt(3) * (r + q/2), hex_height * z ];

gallery(hex2coord(0, 0, 0), 22, hex_height, stair_dia, layout=[0, 1, 1, 0, 1, 1]);
gallery(hex2coord(1, 0, 0), 22, hex_height, stair_dia, layout=[0, 0, 1, 1, 1, 1]);
gallery(hex2coord(1, -1, 0), 22, hex_height, stair_dia, layout=[0, 1, 1, 1, 0, 1]);
gallery(hex2coord(0, -1, 0), 22, hex_height, stair_dia, layout=[0, 1, 1, 0, 1, 1]);
gallery(hex2coord(-1, 0, 0), 22, hex_height, stair_dia, layout=[0, 1, 1, 0, 1, 1]);
gallery(hex2coord(-1, 1, 0), 22, hex_height, stair_dia, layout=[0, 1, 0, 1, 1, 1]);
gallery(hex2coord(0, 1, 0), 22, hex_height, stair_dia, layout=[1, 1, 0, 1, 0, 1]);

gallery(hex2coord(0, 0, 1), 22, hex_height, stair_dia, layout=[1, 0, 1, 1, 0, 1]);
gallery(hex2coord(1, 0, 1), 22, hex_height, stair_dia, layout=[1, 1, 0, 1, 0, 1]);
gallery(hex2coord(0, 1, 1), 22, hex_height, stair_dia, layout=[1, 0, 1, 0, 1, 1]);
gallery(hex2coord(-1, 1, 1), 22, hex_height, stair_dia, layout=[1, 0, 1, 1, 0, 1]);
