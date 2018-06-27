################################################################################
#
#   METHODS FOR CONSTRUCTION OF PATHS INSIDE THE BZ OF A UNITCELL
#
#   STRUCTURE OF THE FILE
#
#   1) TYPE PATH
#       - type definition
#       - printInfo function
#
#   2) TODO CONSTRUCTION FUNCTIONS PATH
#       - function to add points
#       - TODO function to remove points
#       - function to set the total resolution
#
#   3) TODO DEFAULT PATHS
#
################################################################################


################################################################################
#
#   The type Path
#
################################################################################
"""
    mutable struct Path

The type that contains information on a path (in momentum space). Fields are

    points             :: Array{Array{Float64, 1}, 1}
    point_names        :: Array{String, 1}
    segment_resolution :: Array{Int64, 1}

Note that the length of the `segment_resolution` array should be smaller than
the length of the `points` array by exactly 1.


New `Path` objects can be created with

    Path(points::Array{Array{Float64,1},1}, point_names::Array{String,1}, segment_resolution::Array{Int64,1})
    Path(points::Array{Array{Float64,1},1}, point_names::Array{String,1})
    Path()

or by one of the several default functions to create a default path.





# Examples

```julia-repl
julia> path = Path()
```
"""
mutable struct Path

    # Array of Point coordinates
    points::Array{Array{Float64,1}, 1}

    # Array of Point names
    point_names::Array{String, 1}

    # Array of resolutions (for later calculations)
    segment_resolution::Array{Int64, 1}





    # The Default constructor
    function Path(points::Array{Array{Float64,1},1}, point_names::Array{String,1}, segment_resolution::Array{Int64,1})
        return new(points, point_names, segment_resolution)
    end

    # The constructor for a new path without segment resolution information
    function Path(points::Array{Array{Float64,1},1}, point_names::Array{String,1})
        return new(points, point_names, ones(Int64, length(point_names)-1).*100)
    end

    # The constructor for a new path without information
    function Path()
        return new(Array{Float64,1}[], String[], Int64[])
    end

end


# export the type
export Path






################################################################################
#
#   Some functions to print information on the path
#
################################################################################

# Function to print some information on a path
"""
    printInfo(path::Path [; detailed::Bool])

prints (detailed) information on a `Path` object `path`. If detailed output is desired, the complete path will be printed.


# Examples

```julia-repl
julia> printInfo(path)
...

julia> printInfo(path, detailed=true)
...
```
"""
function printInfo(path::Path; detailed::Bool=false)
    # distinguish detailed vs. non-detailed
    if detailed
        # print the complete path
        println("Path overview:")
        # maybe already abort if no points or only one point in path
        if length(path.points) == 0
            println("   (no points defined)")
            return nothing
        elseif length(path.points) == 1
            println("  ($(1)) \"$(path.point_names[1])\" at $(path.points[1])  (only point in path)")
            return nothing
        end
        # alternate between points and segments
        for i in 1:length(path.points)-1
            # print the point
            println("  ($(i)) \"$(path.point_names[i])\" at $(path.points[i])")
            # print the outgoing segment
            println("         |  (resolution: $(path.segment_resolution[i]))")
        end
        # print the last point
        println("  ($(length(path.points))) \"$(path.point_names[length(path.points)])\" at $(path.points[length(path.points)])")
    else
        # not detailed, just give the number of segments and the total resolution
        println("Path contains $(length(path.points)) points ($(length(path.segment_resolution)) segments) with a total resolution of $(sum(path.segment_resolution)).")
    end
end

# export the function
export printInfo






################################################################################
#
#   CONSTRUCTION OF PATHS
#
################################################################################


# Add a point
"""
    addPointToPath!(path::Path, point::Array{Float64,1}, point_name::String [, resolution::Int64=100])

adds a new point to an existing `Path` object. The new point has to be specified by a name and a location.
Optionally, a resolution of the segment to the preceeding point can be given as well.
Note, that only a resolution will be added if there are already points in the path.
In this function, the path object will be changed and no new object will be created.


# Examples

```julia-repl
julia> addPointToPath!(path, [0.0, 0.0], "Gamma")

julia> addPointToPath!(path, [0.0, pi], "M", 150)
```
"""
function addPointToPath!(path::Path, point::Array{Float64,1}, point_name::String, resolution::Int64=100)
    # push the values into the lists
    push!(path.points, point)
    push!(path.point_names, point_name)
    # maybe push resolution, if there were already some points
    if length(path.points) > 1
        push!(path.segment_resolution, resolution)
    end
    # return nothing
    return nothing
end
# Function for when points including pi are added (not of type Float64)
function addPointToPath!(path::Path, point::Array, point_name::String, resolution::Int64=100)
    # push the values into the lists
    push!(path.points, point)
    push!(path.point_names, point_name)
    # maybe push resolution, if there were already some points
    if length(path.points) > 1
        push!(path.segment_resolution, resolution)
    end
    # return nothing
    return nothing
end

# export the function
export addPointToPath!







# scale the resolution by some factor
"""
    scaleResolution!(path::Path, factor::Float64)

scales all segment resolutions of the path by a factor and converts them back to `Int64`.
The path object will be changed and no new object will be created.


# Examples

```julia-repl
julia> scaleResolution!(path, 1.5)
```
"""
function scaleResolution!(path::Path, factor::Float64)
    # multiply all segments
    for s in 1:length(path.segment_resolution)
        path.segment_resolution[s] = round(Int64, path.segment_resolution[s]*factor)
    end
end

# export the function
export scaleResolution!


# set the total resolution
"""
    setTotalResolution!(path::Path, resolution::Int64)

scales all segment resolutions of the path by a factor to match the total resolution `resolution`
and converts them back to `Int64`. The new sum over all segments will give approximately `resolution` (up to float/int conversion).
The path object will be changed and no new object will be created.


# Examples

```julia-repl
julia> setTotalResolution!(path, 1500)
```
"""
function setTotalResolution!(path::Path, resolution::Int64)
    # determine the factor
    factor = resolution / sum(path.segment_resolution)
    # apply the factor
    scaleResolution!(path, factor)
end

# export the function
export setTotalResolution!






################################################################################
#
#   DEFAULT PATHS
#
################################################################################



"""
    getDefaultPathTriangular( [; resolution::Int64=900])

creates the default path for the triangular lattice. Points in this path are

    [0.0, 0.0]               ("Gamma")
    [2*pi/sqrt(3.0), 2*pi/3] ("K")
    [2*pi/sqrt(3.0), 0.0]    ("M")
    [0.0, 0.0]               ("Gamma")

Additionally, a resolution can be set so that the entire path in total has this resolution.

# Examples
```julia-repl
julia> path = getDefaultPathTriangular()
LatticePhysics.Path(...)

julia> path = getDefaultPathTriangular(resolution=1200)
LatticePhysics.Path(...)
```
"""
function getDefaultPathTriangular( ; resolution::Int64=900)
    # create a new path object
    path = Path()
    # insert points
    addPointToPath!(path, [0.0, 0.0], "Gamma")
    addPointToPath!(path, [2*pi/sqrt(3.0), 2*pi/3], "K")
    addPointToPath!(path, [2*pi/sqrt(3.0), 0.0], "M")
    addPointToPath!(path, [0.0, 0.0], "Gamma")
    # set the total resolution
    setTotalResolution!(path, resolution)
    # return the path
    return path
end

# export the function
export getDefaultPathTriangular




"""
    getDefaultPathSquare(version::Int64=1 [; resolution::Int64])

creates the default path for the square lattice. Points in this path are dependent on the version.

Additionally, a resolution can be set so that the entire path in total has this resolution.



# Versions

#### Version 1 (DEFAULT) - short

Points are given by

    [0.0, 0.0]  ("Gamma")
    [ pi, 0.0]  ("M")
    [ pi,  pi]  ("K")
    [0.0, 0.0]  ("Gamma")


#### Version 2 - long / extended

Points are given by

    [0.0, 0.0]  ("Gamma")
    [ pi, 0.0]  ("M")
    [ pi,  pi]  ("K")
    [0.0, 0.0]  ("Gamma")


# Examples
```julia-repl
julia> path = getDefaultPathSquare()
LatticePhysics.Path(...)

julia> path = getDefaultPathSquare(2)
LatticePhysics.Path(...)

julia> path = getDefaultPathSquare(resolution=1200)
LatticePhysics.Path(...)
```
"""
function getDefaultPathSquare(version::Int64=1; resolution::Int64=1000)
    # create a new path object
    path = Path()
    # distinguish between version
    if version == 1
        # insert points
        addPointToPath!(path, [0.0, 0.0], "Gamma")
        addPointToPath!(path, [ pi, 0.0], "M")
        addPointToPath!(path, [ pi,  pi], "K")
        addPointToPath!(path, [0.0, 0.0], "Gamma")
    elseif version == 2
        # insert points
        addPointToPath!(path, [ pi, 0.0], "M")
        addPointToPath!(path, [0.0, 0.0], "Gamma")
        addPointToPath!(path, [ pi, -pi], "K'")
        addPointToPath!(path, [ pi, 0.0], "M")
        addPointToPath!(path, [0.0,  pi], "M'")
        addPointToPath!(path, [ pi,  pi], "K")
        addPointToPath!(path, [0.0, 0.0], "Gamma")
    else
        println("version $(version) unknown")
    end
    # set the total resolution
    setTotalResolution!(path, resolution)
    # return the path
    return path
end


















# SOME DEFAULT PATHS
DEFAULT_PATH_FCC = Array[
    ["gamma"; [0,0,0]],
    ["X"; [2*pi, 0, 0]],
    ["W"; [2*pi, pi, 0]],
    ["L"; [pi, pi, pi]],
    ["gamma"; [0,0,0]],
    ["K"; [3*pi/2, 3*pi/2, 0]],
    ["X"; [2*pi, 0, 0]]
]
export DEFAULT_PATH_FCC


DEFAULT_PATH_SQUAREOCTAGON_2 = Array[
    ["gamma"; [0,0]],
    ["K"; [2,  0].*(pi / (1.0 + 1.0/sqrt(2.0)))],
    ["M"; [1, -1].*(pi / (1.0 + 1.0/sqrt(2.0)))],
    ["gamma"; [0,0]]
]
export DEFAULT_PATH_SQUAREOCTAGON_2
