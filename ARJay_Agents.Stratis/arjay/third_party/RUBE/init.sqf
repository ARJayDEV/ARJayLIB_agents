/*
   RUBE
    the init file
*/

if (!isnil "RUBE_fnc_init") exitWith {};

// string functions
RUBE_inString = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_inString.sqf";
RUBE_isSuffix = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_isSuffix.sqf";
RUBE_pad = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_pad.sqf";

// math, statistics
RUBE_average = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_average.sqf";
RUBE_descriptiveStatistics = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_descriptiveStatistics.sqf";
RUBE_erfcc = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_erfcc.sqf";
RUBE_pearsonCorrelation = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_pearsonCorrelation.sqf";
RUBE_histogram = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_histogram.sqf";
RUBE_chance = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_chance.sqf";
RUBE_roundTo = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_roundTo.sqf";
RUBE_randomWalk = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomWalk.sqf";
RUBE_randomGauss = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomGauss.sqf";
RUBE_neville = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_neville.sqf";
RUBE_bezier = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_bezier.sqf";
RUBE_bspline = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_bspline.sqf";

// (world/map) geometry
RUBE_averagePosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_averagePosition.sqf";
RUBE_bearing = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_bearing.sqf";
RUBE_dirDiff = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_dirDiff.sqf";
RUBE_dirInArc = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_dirInArc.sqf";
RUBE_lineSegmentIntersection = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_lineSegmentIntersection.sqf";
RUBE_convexHull = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_convexHull.sqf";
RUBE_polygonCentroid = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_polygonCentroid.sqf";
RUBE_polygonArea = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_polygonArea.sqf";
RUBE_distanceFilter = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_distanceFilter.sqf";

// date, time
RUBE_sun = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_sun.sqf";
RUBE_moonphase = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_moonphase.sqf";
RUBE_weekday = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_weekday.sqf";
RUBE_daylightHours = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_daylightHours.sqf";
RUBE_seasonCoeff = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_seasonCoeff.sqf";

// arrays, matrices, data-structures...
RUBE_insertSort = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_insertSort.sqf";
RUBE_shellSort = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_shellSort.sqf";
RUBE_arrayReverse = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayReverse.sqf";
RUBE_arrayMin = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayMin.sqf";
RUBE_arrayMax = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayMax.sqf";
RUBE_arrayMap = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayMap.sqf";
RUBE_arrayFilter = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayFilter.sqf";
RUBE_arrayDropIndex = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayDropIndex.sqf";
RUBE_arraySwap = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arraySwap.sqf";
RUBE_arrayMultiMerge = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayMultiMerge.sqf";
RUBE_arrayAppend = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayAppend.sqf";
RUBE_arrayInsert = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayInsert.sqf";
RUBE_arrayInterpolate = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_arrayInterpolate.sqf";
RUBE_distribute = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_distribute.sqf";
RUBE_multipass = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_multipass.sqf";

// classes, sides and factions
RUBE_isMale = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_isMale.sqf";
RUBE_initSides = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_initSides.sqf";
RUBE_extractConfigEntries = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_extractConfigEntries.sqf";
RUBE_isWeapon = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_isWeapon.sqf";
RUBE_isMagazine = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_isMagazine.sqf";
RUBE_selectCrew = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectCrew.sqf";
RUBE_spawnVehicle = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnVehicle.sqf";
RUBE_spawnCrew = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnCrew.sqf";
RUBE_selectFactionInfo = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionInfo.sqf";
RUBE_selectFactionUnit = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionUnit.sqf";
RUBE_selectFactionWeapon = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionWeapon.sqf";
RUBE_selectFactionAmmobox = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionAmmobox.sqf";
RUBE_selectFactionBuilding = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionBuilding.sqf";
RUBE_selectFactionVehicle = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectFactionVehicle.sqf";
RUBE_selectCivilian = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectCivilian.sqf";
RUBE_selectCivilianCar = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_selectCivilianCar.sqf";
RUBE_spawnFactionUnit = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnFactionUnit.sqf";
RUBE_spawnFactionGroup = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnFactionGroup.sqf";
RUBE_spawnCivilians = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnCivilians.sqf";

// random values & positions
RUBE_randomPop = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomPop.sqf";
RUBE_randomBetween = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomBetween.sqf";
RUBE_randomSelect = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomSelect.sqf";
RUBE_randomSubSet = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomSubSet.sqf";
RUBE_randomizeValue = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomizeValue.sqf";
RUBE_randomizePos = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomizePos.sqf";
RUBE_randomCirclePositions = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomCirclePositions.sqf";
RUBE_randomWorldPosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomWorldPosition.sqf";
RUBE_randomLocation = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_randomLocation.sqf";

// units & groups
RUBE_groupReady = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_groupReady.sqf";
RUBE_aliveGroup = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_aliveGroup.sqf";
RUBE_deleteGroup = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_deleteGroup.sqf";
RUBE_getVehicleCrew = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getVehicleCrew.sqf";
RUBE_getGroupVehicles = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getGroupVehicles.sqf";
RUBE_assignAsTurret = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_assignAsTurret.sqf";
RUBE_splitGroup = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_splitGroup.sqf";
RUBE_removeWeapon = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_removeWeapon.sqf";
RUBE_removeHandgun = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_removeHandgun.sqf";
RUBE_updateWaypoint = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_updateWaypoint.sqf";
RUBE_makeKnown = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeKnown.sqf";
RUBE_getEnemyContact = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getEnemyContact.sqf";
RUBE_isEngaging = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_isEngaging.sqf";

// objects, buildings, positions, directions, etc.
RUBE_createTrigger = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_createTrigger.sqf";
RUBE_normalizeDirection = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_normalizeDirection.sqf";
RUBE_getALD = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getALD.sqf";
RUBE_getPosASL = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getPosASL.sqf";
RUBE_maxFlatEmptyArea = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_maxFlatEmptyArea.sqf";
RUBE_positionExpValue = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_positionExpValue.sqf";
RUBE_sampleTerrain = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_sampleTerrain.sqf";
RUBE_samplePeriphery = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_samplePeriphery.sqf";
RUBE_analyzePeriphery = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_analyzePeriphery.sqf";
RUBE_midwayPosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_midwayPosition.sqf";
RUBE_offsetPosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_offsetPosition.sqf";
RUBE_getTentPositions = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getTentPositions.sqf";
RUBE_getBuildingPositions = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getBuildingPositions.sqf";
RUBE_perimeterRoads = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_perimeterRoads.sqf";
RUBE_closeDoors = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_closeDoors.sqf";
RUBE_blast = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_blast.sqf";
RUBE_boundingBoxSize = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_boundingBoxSize.sqf";
RUBE_scaledBoundingBox = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_scaledBoundingBox.sqf"; 
RUBE_setArmament = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_setArmament.sqf";
RUBE_setLoadout = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_setLoadout.sqf";
RUBE_getObjectDimensions = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_getObjectDimensions.sqf";
RUBE_objectInDesert = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_objectInDesert.sqf";
RUBE_rectangleBlockSplit = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_rectangleBlockSplit.sqf";
RUBE_rectanglePacker = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_rectanglePacker.sqf";
RUBE_gridCellDepth = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_gridCellDepth.sqf";
RUBE_gridCellPosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_gridCellPosition.sqf";
RUBE_gridOffsetPosition = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_gridOffsetPosition.sqf";
RUBE_spawnObjects = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnObjects.sqf";
RUBE_spawnObjectChain = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnObjectChain.sqf";
RUBE_spawnObjectCircle = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnObjectCircle.sqf";
RUBE_spawnObjectCloud = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnObjectCloud.sqf";
RUBE_spawnObjectGrid = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnObjectGrid.sqf";
RUBE_spawnTable = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnTable.sqf";
RUBE_spawnPackedArea = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_spawnPackedArea.sqf";
RUBE_packVehicle = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_packVehicle.sqf";

// input listeners
RUBE_addInputListener = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_addInputListener.sqf";
RUBE_removeInputListener = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_removeInputListener.sqf";
(call (compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_addInputListenerLib.sqf"));

// actions
RUBE_addAction = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_addAction.sqf";
RUBE_removeAction = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_removeAction.sqf";

// action: dragg-/droppable objects
RUBE_makeDroppable = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeDroppable.sqf";
RUBE_makeDraggable = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeDraggable.sqf";
(call (compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeDraggableLib.sqf"));

// action: buildables and supplies
RUBE_makeBuildable = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeBuildable.sqf";
(call (compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeBuildableLib.sqf"));
(call (compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_makeSuppliesLib.sqf"));

// map & markers
RUBE_readMarkers = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_readMarkers.sqf";
RUBE_mapDrawLine = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_mapDrawLine.sqf";
RUBE_mapDrawMarker = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_mapDrawMarker.sqf";
RUBE_findRoute = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_findRoute.sqf";
RUBE_plotRoute = compile preprocessFileLineNumbers "arjay\third_party\RUBE\fn\fn_plotRoute.sqf";

// done
waitUntil{!isnil "BIS_fnc_init"};
RUBE_fnc_init = true;