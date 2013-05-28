<?xml version="1.0" encoding="UTF-8"?>
<tileset name="grasslands" tilewidth="64" tileheight="64">
 <image source="grasslands.png" width="768" height="832"/>
 <terraintypes>
  <terrain name="grass_light" tile="-1"/>
  <terrain name="grass_medium" tile="-1"/>
  <terrain name="grass_heavy" tile="-1"/>
  <terrain name="water_shallow" tile="-1"/>
  <terrain name="water_deep" tile="-1"/>
  <terrain name="dirt" tile="-1"/>
  <terrain name="brick" tile="-1"/>
  <terrain name="brick_dirty" tile="-1"/>
  <terrain name="hole" tile="-1"/>
 </terraintypes>
 <tile id="0" terrain="1,1,1,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="1" terrain="1,1,0,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="2" terrain="1,1,0,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="3" terrain="2,2,2,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="4" terrain="2,2,1,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="5" terrain="2,2,1,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="6" terrain="1,1,1,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="7" terrain="1,1,3,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="8" terrain="1,1,3,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="9" terrain="3,3,3,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="10" terrain="3,3,4,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="11" terrain="3,3,4,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="12" terrain="1,0,1,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="13" terrain="0,0,0,0">
  <properties>
   <property name="terrain_type" value="light_grass"/>
  </properties>
 </tile>
 <tile id="14" terrain="0,1,0,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="15" terrain="2,1,2,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="16" terrain="1,1,1,1">
  <properties>
   <property name="default_tile" value="YES"/>
   <property name="terrain_type" value="medium_grass"/>
  </properties>
 </tile>
 <tile id="17" terrain="1,2,1,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="18" terrain="1,3,1,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="19" terrain="3,3,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water"/>
  </properties>
 </tile>
 <tile id="20" terrain="3,1,3,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="21" terrain="3,4,3,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="22" terrain="4,4,4,4">
  <properties>
   <property name="blocks_movement" value="1"/>
   <property name="terrain_type" value="deep_water"/>
  </properties>
 </tile>
 <tile id="23" terrain="4,3,4,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="24" terrain="1,0,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="25" terrain="0,0,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="26" terrain="0,1,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="27" terrain="2,1,2,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="28" terrain="1,1,2,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="29" terrain="1,2,2,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="30" terrain="1,3,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="31" terrain="3,3,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="32" terrain="3,1,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="33" terrain="3,4,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="34" terrain="4,4,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="35" terrain="4,3,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="36" terrain="0,0,0,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="37" terrain="0,0,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="38" terrain="0,0,1,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="39" terrain="1,1,1,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="40" terrain="1,1,2,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="41" terrain="1,1,2,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="42" terrain="3,3,3,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="43" terrain="3,3,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="44" terrain="3,3,1,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="45" terrain="4,4,4,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="46" terrain="4,4,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="47" terrain="4,4,3,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="48" terrain="0,1,0,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="49" terrain="1,1,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass"/>
  </properties>
 </tile>
 <tile id="50" terrain="1,0,1,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="51" terrain="1,2,1,2">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="52" terrain="2,2,2,2">
  <properties>
   <property name="terrain_type" value="deep_grass"/>
  </properties>
 </tile>
 <tile id="53" terrain="2,1,2,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="54" terrain="3,1,3,1">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="55" terrain="1,1,1,1">
  <properties>
   <property name="terrain_type" value="medium_grass"/>
  </properties>
 </tile>
 <tile id="56" terrain="1,3,1,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="57" terrain="4,3,4,3">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="58" terrain="3,3,3,3">
  <properties>
   <property name="terrain_type" value="shallow_water"/>
  </properties>
 </tile>
 <tile id="59" terrain="3,4,3,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="60" terrain="0,1,0,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="61" terrain="1,1,0,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="62" terrain="1,0,0,0">
  <properties>
   <property name="terrain_type" value="medium_grass_border_light_grass"/>
  </properties>
 </tile>
 <tile id="63" terrain="1,2,1,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="64" terrain="2,2,1,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="65" terrain="2,1,1,1">
  <properties>
   <property name="terrain_type" value="deep_grass_border_medium_grass"/>
  </properties>
 </tile>
 <tile id="66" terrain="3,1,3,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="67" terrain="1,1,3,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="68" terrain="1,3,3,3">
  <properties>
   <property name="terrain_type" value="medium_grass_border_shallow_water"/>
  </properties>
 </tile>
 <tile id="69" terrain="4,3,4,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="70" terrain="3,3,4,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="71" terrain="3,4,4,4">
  <properties>
   <property name="terrain_type" value="shallow_water_border_deep_water"/>
  </properties>
 </tile>
 <tile id="72" terrain="5,5,5,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="73" terrain="5,5,0,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="74" terrain="5,5,0,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="75" terrain="8,8,8,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="76" terrain="8,8,5,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="77" terrain="8,8,5,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="78" terrain="6,6,6,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="79" terrain="6,6,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="80" terrain="6,6,7,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="81" terrain="7,7,7,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="82" terrain="7,7,5,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="83" terrain="7,7,5,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="84" terrain="5,0,5,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="85" terrain="0,0,0,0">
  <properties>
   <property name="terrain_type" value="light_grass"/>
  </properties>
 </tile>
 <tile id="86" terrain="0,5,0,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="87" terrain="8,5,8,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="88" terrain="5,5,5,5">
  <properties>
   <property name="terrain_type" value="dirt"/>
  </properties>
 </tile>
 <tile id="89" terrain="5,8,5,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="90" terrain="6,7,6,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="91" terrain="7,7,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick"/>
  </properties>
 </tile>
 <tile id="92" terrain="7,6,7,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="93" terrain="7,5,7,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="94" terrain="5,5,5,5">
  <properties>
   <property name="terrain_type" value="dirt"/>
  </properties>
 </tile>
 <tile id="95" terrain="5,7,5,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="96" terrain="5,0,5,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="97" terrain="0,0,5,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="98" terrain="0,5,5,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="99" terrain="8,5,8,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="100" terrain="5,5,8,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="101" terrain="5,8,8,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="102" terrain="6,7,6,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="103" terrain="7,7,6,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="104" terrain="7,6,6,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="105" terrain="7,5,7,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="106" terrain="5,5,7,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="107" terrain="5,7,7,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="108" terrain="0,0,0,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="109" terrain="0,0,5,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="110" terrain="0,0,5,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="111" terrain="5,5,5,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="112" terrain="5,5,8,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="113" terrain="5,5,8,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="114" terrain="7,7,7,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="115" terrain="7,7,6,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="116" terrain="7,7,6,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="117" terrain="5,5,5,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="118" terrain="5,5,7,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="119" terrain="5,5,7,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="120" terrain="0,5,0,5">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="121" terrain="5,5,5,5">
  <properties>
   <property name="terrain_type" value="dirt"/>
  </properties>
 </tile>
 <tile id="122" terrain="5,0,5,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="123" terrain="5,8,5,8">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="124" terrain="8,8,8,8">
  <properties>
   <property name="terrain_type" value="hole"/>
   <property name="will_fall" value="YES"/>
  </properties>
 </tile>
 <tile id="125" terrain="8,5,8,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="126" terrain="7,6,7,6">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="127" terrain="6,6,6,6">
  <properties>
   <property name="terrain_type" value="brick"/>
  </properties>
 </tile>
 <tile id="128" terrain="6,7,6,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="129" terrain="5,7,5,7">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="130" terrain="7,7,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick"/>
  </properties>
 </tile>
 <tile id="131" terrain="7,5,7,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="132" terrain="0,5,0,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="133" terrain="5,5,0,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="134" terrain="5,0,0,0">
  <properties>
   <property name="terrain_type" value="light_grass_border_dirt"/>
  </properties>
 </tile>
 <tile id="135" terrain="5,8,5,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="136" terrain="8,8,5,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="137" terrain="8,5,5,5">
  <properties>
   <property name="might_fall" value="YES"/>
   <property name="terrain_type" value="dirt_border_hole"/>
  </properties>
 </tile>
 <tile id="138" terrain="7,6,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="139" terrain="6,6,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="140" terrain="6,7,7,7">
  <properties>
   <property name="terrain_type" value="dirty_brick_border_brick"/>
  </properties>
 </tile>
 <tile id="141" terrain="5,7,5,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="142" terrain="7,7,5,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="143" terrain="7,5,5,5">
  <properties>
   <property name="terrain_type" value="dirt_border_dirty_brick"/>
  </properties>
 </tile>
 <tile id="145">
  <properties>
   <property name="blocks_movement" value="1"/>
  </properties>
 </tile>
 <tile id="146">
  <properties>
   <property name="entry_exit" value="1"/>
  </properties>
 </tile>
</tileset>
