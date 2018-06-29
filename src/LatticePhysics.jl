#-----------------------------------------------------------------------------------------------------------------------------
#
#   The unified Module for all different sorts of lattices
#   Includes the following structure:
#
#   -   Definition of UNITCELL TYPE
#       -   saving / loading Unitcell
#   -   Definition of LATTICE TYPE
#       -   saving / loading Lattice
#       -   information on Lattice
#       -   connectivities of Lattice
#
#   -   Functions to generate Unitcell objects for 2D lattices
#   -   Functions to generate Unitcell objects for 3D lattices
#   -   Function to generate Unitcell object from collection of points
#   -   Function to print generating code for a given Unitcell object
#
#   -   Building Lattices as (periodic/open/semiperiodic) repeated patterns of Unitcells for 2D unitcells
#   -   Building Lattices as (periodic/open/semiperiodic) repeated patterns of Unitcells for 3D unitcells
#   -   Building Lattices as (periodic/open/semiperiodic) repeated patterns of Unitcells for any unitcell
#   -   Building Lattices by bond distance to an origin site
#   -   Building Lattices in a shape around an origin site
#
#   -   Modifying Lattices and Interaction Strengths
#
#   -   TODO SVG help methods
#   -   Plotting Lattices as SVG files
#   -   TODO Calculating dispersions for 1D and 2D fields of k values
#   -   TODO Calculation of Fermi surfaces or surfaces of some energy value
#
#-----------------------------------------------------------------------------------------------------------------------------


# Start of module
module LatticePhysics








#-----------------------------------------------------------------------------------------------------------------------------
#
#   DEPENDENCIES AND USED LIBRARIES
#
#-----------------------------------------------------------------------------------------------------------------------------

# JLD is used for all save / load applications
using JLD

# PyPlot is used for all plotting of band structures (plotting of lattices is done via SVG file creation)
using PyCall
using PyPlot

# Optim is used for minimizing the band structure to find the ground state energy of the system
#using Optim







#-----------------------------------------------------------------------------------------------------------------------------
#
#   SOME FILENAMES AND DEFAULT PATHS
#
#-----------------------------------------------------------------------------------------------------------------------------

# THE FOLDER FOR UNITCELLS
FOLDER_UNITCELLS = "unitcells/"
# THE FOLDER FOR LATICES
FOLDER_LATTICES = "lattices/"

# export the folders
export FOLDER_UNITCELLS
export FOLDER_LATTICES

# Dummy filenames
UNITCELL_DUMMY_FILENAME = "THIS IS NOT A UNIT CELL"
LATTICE_DUMMY_FILENAME = "THIS IS NOT A LATTICE"
export UNITCELL_DUMMY_FILENAME
export LATTICE_DUMMY_FILENAME




# THE FOLDER FOR BAND STRUCTURES
FOLDER_SPECTRA = "band_structures/"

# export the folder
export FOLDER_SPECTRA






#-----------------------------------------------------------------------------------------------------------------------------
#
#   FUNCTIONS TO ENSURE DEFAULT PATHS EXIST
#
#-----------------------------------------------------------------------------------------------------------------------------
function buildFolderUnitcells()
    mkpath(FOLDER_UNITCELLS)
end
export buildFolderUnitcells
function buildFolderLattices()
    mkpath(FOLDER_LATTICES)
end
export buildFolderLattices
function buildFolderSpectra()
    mkpath(FOLDER_SPECTRA)
end
export buildFolderSpectra


function buildFolders()
    buildFolderUnitcells()
    buildFolderLattices()
    buildFolderSpectra()
end
export buildFolders










################################################################################
#
#   TYPE DEFINITIONS OF OBJECT CLASSES IN JULIA
#
#   STRUCTURE OF THE FILE "LatticePhysics_type_definitions.jl"
#
#   1) Definition of UNITCELL OBJECT
#       - Saving
#       - Loading
#
#   2) Definition of LATTICE OBJECT
#       - Saving
#       - Loading
#
#   3) CONVERSION LATTICE --> UNITCELL
#
#   4) OBTAINING GENERAL INFORMATION
#       - Testing a Unitcell object
#       - Print Information (printInfo(..))
#       - obtain the connection strengths of an object
#
#   5) OBTAINING CONNECTIVITY INFORMATION
#       - getConnectivityList(..)
#       - getConnectionList(..)
#
################################################################################

# included in subfile
include("LatticePhysics_type_definitions.jl")






################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT UNITCELLS in 2D and 3D
#
#   STRUCTURE OF THE FILE
#
#   2D UNITCELLS
#   - SQUARE / RECTANGLE
#       - getUnitcellSquare
#       - getUnitcellExtendedSquare
#       - getUnitcellCheckerboard
#       - getUnitcellShastrySutherland
#       - getUnitcellAdvancedSquare
#       - getUnitcellSquareOctagon
#       - getUnitcellBCC2D
#       - getUnitcellFullyConnectedSquare
#   - TRIANGULAR
#       - getUnitcellTriangular
#       - getUnitcellHoneycomb
#       - getUnitcellKagome
#       - getUnitcellKagomeMinus
#       - getUnitcellHoneycombXXX
#
#   3D UNITCELLS
#   - CUBIC / FCC
#       - getUnitcellDiamond
#       - getUnitcellBCC
#       - getUnitcellPyrochlore
#   - (X,3)y FAMILY
#       - getUnitcell_8_3_a
#       - getUnitcell_8_3_b
#       - getUnitcell_8_3_c
#       - getUnitcell_8_3_n
#       - getUnitcell_9_3_a
#       - getUnitcell_10_3_a / getUnitcellHyperoctagon
#       - getUnitcell_10_3_b / getUnitcellHyperhoneycomb
#       - getUnitcell_10_3_c
#       - getUnitcell_10_3_d
#
################################################################################

# included in subfile
include("LatticePhysics_unitcell_implementations.jl")




################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT UNITCELL CONSTRUCTION RELATED STUFF
#
#   STRUCTURE OF THE FILE
#
#   1) UNITCELL FROM SITE COLLECTION (automatically determine the connections)
#       - 2D
#       - 3D
#       - independent of the dimension
#
#   2) UNITCELL GENERATING CODE
#
################################################################################

# included in subfile
include("LatticePhysics_unitcell_construction.jl")







################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT LATTICE CONSTRUCTION RELATED STUFF
#
#   STRUCTURE OF THE FILE
#
#   1) CONSTRUCTION BASED ON UNITCELLS (2D & 3D)
#   - Periodic Boundaries
#   - Open Boundaries
#   - Semi-Periodic Boundaries
#   - General Boundaries
#
#   2) CONSTRUCTION BASED ON BOND DISTANCE (2D & 3D)
#
#   3) CONSTRUCTION BASED ON SHAPE (2D & 3D)
#   - General Shape
#   - Sphere
#   - Box
#
################################################################################

# included in subfile
include("LatticePhysics_lattice_construction.jl")



################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT LATTICE MODIFICATION FUNCTIONS
#   (MOST OF THEM ALSO WORK FOR UNITCELLS)
#
#   STRUCTURE OF THE FILE
#
#   1) CONNECTIONS ADDING REMOVING
#       - Add a new connection
#       - remove connections (based on indices)
#       - remove connections (based on strength)
#
#   2) SITES ADDING REMOVING
#       - add a new site
#       - remove a site (based on index)
#
#   3) CONNECTION STRENGTH MODIFICATION
#       - all connections
#       - mapping of strengths
#       - evaluate strengths
#       - optimize connections
#
################################################################################

# included in subfile
include("LatticePhysics_lattice_modification.jl")








################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT PLAQUETTE RELATED FUNCTIONS
#
#   STRUCTURE OF THE FILE
#
#   1) FINDING PLAQUETTES IN LATTICE OBJECTS
#   - of a site
#   - of complete lattice
#
#   2) PRINTING PLAQUETTE STATISTICS
#   - of a site
#   - of complete lattice
#
#
#   BUG: Plaquettes dont implement periodic boundaries so far
#
################################################################################

# included in subfile
include("LatticePhysics_plaquette_operations.jl")



################################################################################
#
#   METHODS FOR CONSTRUCTION INTERACTION MATRICES FOR LATTICES
#
#   STRUCTURE OF THE FILE
#
#   1) INTERACTION MATRICES IN REAL SPACE
#
#   2) INTERACTION MATRICES IN MOMENTUM SPACE
#
#   NOTE: No Majorana fermions so far on the level of matrices, because of some
#   problems with the various gauges that can be tuned. Want: sublattice
#   idenfitication in bipartite systems.
#
################################################################################

# included in subfile
include("LatticePhysics_interaction_matrices.jl")





################################################################################
#
#   METHODS FOR CONSTRUCTION OF PATHS INSIDE THE BZ OF A UNITCELL
#
#   STRUCTURE OF THE FILE
#
#   1) TYPE PATH
#       - type definition
#       - printInfo function
#       - path String function (e.g. X-G-M-X)
#
#   2) CONSTRUCTION FUNCTIONS PATH
#       - function to add points
#       - TODO function to remove points
#       - function to scale the total resolution
#       - function to set the total resolution
#
#   3) DEFAULT PATHS
#       - getDefaultPathTriangular
#       - getDefaultPathSquare
#       - getDefaultPathSquareOctagon
#       - getDefaultPathFCC
#
#   4) TODO FUNCTION TO CREATE A DEFAULT PATH BASED ON A UNITCELL OBJECT
#
################################################################################

# included in subfile
include("LatticePhysics_paths.jl")






################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT LATTICE PLOTTING FUNCTIONS FOR
#   PLOTTING TO SVG IMAGES
#
#   STRUCTURE OF THE FILE
#
#   1) HELPER SVG FUNCTIONS
#       - Header / Footer String
#       - Ellipse (stroked) String
#       - Line String
#       - Plaquette String
#       - Color conversion
#       - Color collections / sequences
#
#   2) PLOTTING LATTICES
#       - plot in 2D
#       - TODO plot in 3D
#       - TODO plot independent of dimension
#
#   3) PLOTTING PLAQUETTES (only 2D)
#
################################################################################

# included in subfile
include("LatticePhysics_SVG_plotting.jl")



################################################################################
#
#   METHODS FOR CONSTRUCTION OF BANDSTRUCTURES (ALONG PATHS)
#
#   STRUCTURE OF THE FILE
#
#   1) TYPE BANDSTRUCTURE
#       - type definition
#       - TODO printInfo function
#
#   2) CALCULATION OF BAND STRUCTURES OF UNTICELL OBJECTS
#
#   3) PLOTTING OF BAND STRUCTURES
#       - plotting of Bandstructure objects
#       - plotting of bandstructures of unitcells along paths
#
################################################################################

# included in subfile
include("LatticePhysics_bandstructures.jl")






################################################################################
#
#   METHODS FOR CONSTRUCTION OF FERMI SURFACES
#
#   STRUCTURE OF THE FILE
#
#   1) CALCULATION OF FERMI SURFACE
#
#   2) PLOTTING OF FERMI SURFACE
#       - plotting from points
#       - plotting from unitcell
#
#   NOTE: So far all of this code is for 2D only!
#
################################################################################

# included in subfile
include("LatticePhysics_fermi_surfaces.jl")













# MODULE END
end
