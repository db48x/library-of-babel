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

module spiral_stair_segment(height=1, stair_dia=in2ft(72), start_angle=0, end_angle=30) {
     cylinder(abs(height), d=in2ft(.5)+in2ft(sqrt(stair_dia)), center=true, $fs=.01, $fa=1);
     translate([0, 0, in2ft(-0.5)]) {
       difference() {
         cylinder(in2ft(1), d=stair_dia, $fs=.1, $fa=5);
         rotate([0, 0, start_angle+180]) {
           translate([-(stair_dia+1)/2, 0, in2ft(-0.5)]) {
             cube([stair_dia+1, stair_dia+1, in2ft(2)]);
           }
         }
         rotate([0, 0, end_angle]) {
           translate([-(stair_dia+1)/2, 0, in2ft(-0.5)]) {
             cube([stair_dia+1, stair_dia+1, in2ft(2)]);
           }
         }
       }
     }
}

module spiral_stair_cutout(height, stair_dia) {
     translate([0, 0, -2]) {
          cylinder(height+8, d=stair_dia, $fs=.1, $fa=5);
     }
}

module spiral_stair(height, stair_dia, railing=false) {
     for (s = [0:1:11]) {
          translate([0, 0, s*height/12]) {
               spiral_stair_segment(height/12, stair_dia, 30*s, 30*s+35);
          }
     }
     if (railing) {
          railing_height = height-2+in2ft(4);
          railing_slope = railing_height/height;
          translate([0, 0, 5-in2ft(2)]) {
               linear_extrude(railing_height, twist=-360*railing_height/height, $fn=72) {
                    rotate([0, 0, 60-60*in2ft(4)/height])
                    translate([stair_dia/2-in2ft(0.5), 0, 0]) {
                         square(in2ft(2), in2ft(1), center=true);
                    }
               }
          }
          for (s = [2:2:13]) {
               rotate([0, 0, 30*s+2.5]) {
                    translate([stair_dia/2-in2ft(0.5), 0, (s-1)*height/12]) {
                         rotate([0, 0, 45]) {
                              cylinder(4, d=in2ft(1), $fn=4);
                         }
                    }
               }
          }
     }
}

module spiral_stair_a(height, stair_dia, railing=false) {
     intersection() {
          spiral_stair(height, stair_dia, railing=railing);
          translate([-(stair_dia+1)/2, -stair_dia/2-1, -0.5]) {
               cube([stair_dia+1, stair_dia/2+1, height+4]);
          }
     }
}

module spiral_stair_b(height, stair_dia, railing=false) {
     intersection() {
          spiral_stair(height, stair_dia, railing=railing);
          translate([-(stair_dia+1)/2, 0, -0.5]) {
               cube([stair_dia+1, stair_dia/2+1, height+4]);
          }
     }
}

module vestibule(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  door_height = in2ft(80);
  width = stair_dia + 2*door_width;
  length = 1.1*(stair_dia + 2*door_width);
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
    // stairs
    translate([width/2, length/2, 0]) {
      spiral_stair(height, stair_dia, railing=true);
    }
  }
}

module vestibule_a(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  width = stair_dia + 2*door_width + 12 + 1;
  length = 1.1*(stair_dia + 2*door_width);
  intersection() {
       vestibule(height, stair_dia, door_width);
       translate([-width/2-1, -length/2-2, -1]) {
         cube([width+2, length/2+2, height+2]);
       }
  }
}

module vestibule_b(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  width = stair_dia + 2*door_width + 12 + 1;
  length = 1.1*(stair_dia + 2*door_width);
  intersection() {
       vestibule(height, stair_dia, door_width);
       translate([-width/2-1, 0, -1]) {
         cube([width+2, length/2+2, height+2]);
       }
  }
}

module vestibule_cutout(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  door_height = in2ft(80);
  width = stair_dia + 2*door_width;
  length = 1.1*(stair_dia + 2*door_width)+2;
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

module vestibule_a_cutout(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  width = stair_dia + 2*door_width + 12 + 1;
  length = 1.1*(stair_dia + 2*door_width);
  intersection() {
       vestibule_cutout(height, stair_dia, door_width);
       translate([-width/2-1, -length/2-2, -1]) {
         cube([width+2, length/2+2, height+2]);
       }
  }
}

module vestibule_b_cutout(height, stair_dia=in2ft(48), door_width=in2ft(36)) {
  width = stair_dia + 2*door_width + 12 + 1;
  length = 1.1*(stair_dia + 2*door_width);
  intersection() {
       vestibule_cutout(height, stair_dia, door_width);
       translate([-width/2-1, 0, -1]) {
         cube([width+2, length/2+2, height+2]);
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
  vent_area = (3/2*sqrt(3)*inner_radius*inner_radius)/4;
  vent_radius = sqrt(vent_area/3.141592);
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
        rotate([0, 0, 60*s+30]) {
          translate([outer_apothem, 0, 0]) {
            rotate([0, 0, 90]) {
              if (layout[s]) {
                spiral_stair_cutout(height, stair_dia, railing=true, angle=-120);
              } else {
                if (s % 2) {
                  rotate([0, 0, -180]) {
                    vestibule_cutout(height, stair_dia, door_width);
                  }
                } else {
                  vestibule_cutout(height, stair_dia, door_width);
                }
              }
            }
          }
        }
      }
      // ventilation shaft
      translate([0, 0, -1]) {
        cylinder(3, d=vent_radius*2, $fs=.1, $fa=5);
      }
    }
    // railing
    railing(3, vent_radius*2);
    // vestibules and stairs
    for (s = [0:1:5]) {
      rotate([0, 0, 60*s+30]) {
        translate([outer_apothem, 0, 0]) {
          rotate([0, 0, 90]) {
            if (layout[s]) {
              if (s % 2) {
                rotate([0, 0, -180]) {
                  spiral_stair_a(height, stair_dia, railing=true, angle=-120);
                }
              } else {
                spiral_stair_b(height, stair_dia, railing=true, angle=-120);
              }
            } else {
              if (s % 2) {
                rotate([0, 0, -180]) {
                  vestibule_a(height, stair_dia, door_width);
                }
              } else {
                vestibule_b(height, stair_dia, door_width);
              }
            }
          }
        }
      }
    }
  }
}

stair_dia=in2ft(60);
hex_inner_radius = 16;
hex_radius = gallery_radius(hex_inner_radius, stair_dia);
hex_height = 11;
function hex2coord(q, r, z) = [ hex_radius * 3/2 * q, hex_radius * sqrt(3) * (r + q/2), hex_height * z ];

gallery(hex2coord( 0,  0,  0), hex_inner_radius, hex_height, stair_dia, layout=[0, 1, 1, 1, 0, 1]);
gallery(hex2coord( 1,  0,  0), hex_inner_radius, hex_height, stair_dia, layout=[0, 1, 1, 0, 1, 1]);
gallery(hex2coord( 1, -1,  0), hex_inner_radius, hex_height, stair_dia, layout=[1, 1, 1, 1, 0, 0]);
gallery(hex2coord( 0, -1,  0), hex_inner_radius, hex_height, stair_dia, layout=[1, 0, 1, 0, 1, 1]);
gallery(hex2coord(-1,  0,  0), hex_inner_radius, hex_height, stair_dia, layout=[1, 0, 1, 0, 1, 1]);
gallery(hex2coord(-1,  1,  0), hex_inner_radius, hex_height, stair_dia, layout=[0, 1, 1, 1, 0, 1]);
gallery(hex2coord( 0,  1,  0), hex_inner_radius, hex_height, stair_dia, layout=[1, 0, 1, 0, 1, 1]);

gallery(hex2coord( 0,  0,  1), hex_inner_radius, hex_height, stair_dia, layout=[1, 0, 1, 1, 1, 0]);
gallery(hex2coord( 1,  0,  1), hex_inner_radius, hex_height, stair_dia, layout=[1, 1, 0, 1, 0, 1]);
gallery(hex2coord( 0,  1,  1), hex_inner_radius, hex_height, stair_dia, layout=[1, 1, 1, 1, 0, 0]);
gallery(hex2coord(-1,  1,  1), hex_inner_radius, hex_height, stair_dia, layout=[1, 0, 1, 1, 0, 1]);
