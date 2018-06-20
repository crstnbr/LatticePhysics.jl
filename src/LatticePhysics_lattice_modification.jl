################################################################################
#
#   IMPLEMENTATIONS OF DIFFERENT LATTICE MODIFICATION FUNCTIONS
#   (MOST OF THEM ALSO WORK FOR UNITCELLS)
#
#   STRUCTURE OF THE FILE
#
#   1) TODO CONNECTIONS
#       - TODO Add a new connection
#       - TODO remove connections (based on indices)
#       - TODO remove connections (based on strength)
#       - TODO optimize connections
#
#   2) TODO SITES
#       - TODO add a new site
#       - TODO remove a site (based on index)
#
################################################################################





#-------------------------------------------------------------------------------
#
#  Add connection to given unitcell / lattice objects
#
#-------------------------------------------------------------------------------
"""
    addConnection!(unitcell::Unitcell, index_from::Int64, index_to::Int64, strength [, wrap=-1; overwrite::Bool=false])
    addConnection!(lattice::Lattice,   index_from::Int64, index_to::Int64, strength [, wrap=-1; overwrite::Bool=false])

Function to add a connection to either a `Unitcell` object or a `Lattice` object.
Necessary parameters include the indices of sites between which the connection takes place as well as the strength of the connection.
Additionally (in case of a unitcell or periodic boundaries), a wrap can be specified in terms of lattice vectors.
If no wrap is specified, the wrap will be chosen automatically as without wrapping around periodic boundaries.

The additional option `overwrite` specifies if one wants to simply add the connection
or if one wants to first search if there is a connection that already satisfies the new connection (in which case nothing would be added).

NOTE 1: This function always tries to add two connections, one going forward, one going backward.

NOTE 2: This function modifies the given object and does not create a copy.


# Examples

```julia-repl
julia> addConnection!(unitcell, 1, 3, "tx", (0,1))


julia> addConnection!(lattice, 31, 27, "tx")

```
"""
function addConnection!(unitcell::Unitcell, index_from::Int64, index_to::Int64, strength, wrap=-1; overwrite::Bool=false)

    # maybe default wrap
    if wrap == -1
        if length(unitcell.lattice_vectors) == 3
            wrap = (0,0,0)
        elseif length(unitcell.lattice_vectors) == 2
            wrap = (0,0)
        else
            wrap = (0)
        end
    end

    # construct the returning wrap
    if length(wrap) == 3
        wrap_return = (-wrap[1],-wrap[2],-wrap[3])
    elseif length(wrap) == 2
        wrap_return = (-wrap[1],-wrap[2])
    else
        wrap_return = (-wrap)
    end
    # construct the returning strength
    if typeof(strength) == Complex
        strength_return = copy(conj(strength))
    else
        strength_return = copy(strength)
    end

    # construct the connection as an array
    connection_1 = Any[index_from; index_to; strength; wrap]
    # construct the returning connection as an array
    connection_2 = Any[index_to; index_from; strength_return; wrap_return]

    # if not overwrite, check if the connection exists
    if !overwrite
        # report if found
        found_c1 = false
        found_c2 = false
        # check in all connections
        for c in unitcell.connections
            if  Int(c[1]) == Int(connection_1[1]) && Int(c[2]) == Int(connection_1[2]) && c[3] == connection_1[3] && c[4] == connection_1[4]
                found_c1 = true
            end
            if  Int(c[1]) == Int(connection_2[1]) && Int(c[2]) == Int(connection_2[2]) && c[3] == connection_2[3] && c[4] == connection_2[4]
                found_c2 = true
            end
        end
        # only add if not added already
        if !found_c1
            push!(unitcell.connections, connection_1)
        end
        if !found_c2
            push!(unitcell.connections, connection_2)
        end
    # otherwise, just add the connections
    else
        push!(unitcell.connections, connection_1)
        push!(unitcell.connections, connection_2)
    end

end
function addConnection!(lattice::Lattice, index_from::Int64, index_to::Int64, strength, wrap=-1; overwrite::Bool=false)

    # maybe default wrap
    if wrap == -1
        if length(lattice.lattice_vectors) == 3
            wrap = (0,0,0)
        elseif length(lattice.lattice_vectors) == 2
            wrap = (0,0)
        else
            wrap = (0)
        end
    end

    # construct the returning wrap
    if length(wrap) == 3
        wrap_return = (-wrap[1],-wrap[2],-wrap[3])
    elseif length(wrap) == 2
        wrap_return = (-wrap[1],-wrap[2])
    else
        wrap_return = (-wrap)
    end
    # construct the returning strength
    if typeof(strength) == Complex
        strength_return = copy(conj(strength))
    else
        strength_return = copy(strength)
    end

    # construct the connection as an array
    connection_1 = Any[index_from; index_to; strength; wrap]
    # construct the returning connection as an array
    connection_2 = Any[index_to; index_from; strength_return; wrap_return]

    # if not overwrite, check if the connection exists
    if !overwrite
        # report if found
        found_c1 = false
        found_c2 = false
        # check in all connections
        for c in lattice.connections
            if  Int(c[1]) == Int(connection_1[1]) && Int(c[2]) == Int(connection_1[2]) && c[3] == connection_1[3] && c[4] == connection_1[4]
                found_c1 = true
            end
            if  Int(c[1]) == Int(connection_2[1]) && Int(c[2]) == Int(connection_2[2]) && c[3] == connection_2[3] && c[4] == connection_2[4]
                found_c2 = true
            end
        end
        # only add if not added already
        if !found_c1
            push!(lattice.connections, connection_1)
        end
        if !found_c2
            push!(lattice.connections, connection_2)
        end
    # otherwise, just add the connections
    else
        push!(lattice.connections, connection_1)
        push!(lattice.connections, connection_2)
    end

end
export addConnection!






#-------------------------------------------------------------------------------
#
#   Remove interactions with given strengths of the unitcell / lattice
#
#-------------------------------------------------------------------------------
function removeConnections!(lattice::Lattice, strengthToRemove=0.0)
    connections_new = Array[]
    for c in lattice.connections
        if c[3] != strengthToRemove
            push!(connections_new, c)
        end
    end
    lattice.connections = connections_new;
end
function removeConnections!(unitcell::Unitcell, strengthToRemove=0.0)
    connections_new = Array[]
    for c in unitcell.connections
        if c[3] != strengthToRemove
            push!(connections_new, c)
        end
    end
    unitcell.connections = connections_new;
end

export removeConnections!


#-----------------------------------------------------------------------------------------------------------------------------
#
#   Optimize the lattice / unitcell by collapsing redundant connections into fewer connections and modify given object
#
#-----------------------------------------------------------------------------------------------------------------------------
function optimizeConnections!(lattice::Lattice)
    # build up new connections
    connections_new = Array[]
    # go through all old connections
    for c in lattice.connections
        # check if the connection already is present in the list
        found = false
        for c_new in connections_new
            if c[1] == c_new[1] && c[2] == c_new[2] && c[4] == c_new[4]
                # found a redundent connection
                found = true
                # add connection strength
                if typeof(c[3]) == String || typeof(c_new[3]) == String
                    c_new[3] = "$(c_new[3])+$(c[3])"
                else
                    c_new[3] = c_new[3] + c[3]
                end
                # break the inner loop
                break
            end
        end
        # if not, add the current connection
        if !found
            push!(connections_new, c)
        end
    end
    # check if the connection strength is 0
    connections_new_2 = Array[]
    for c in connections_new
        # check if close to 0 connection strength
        if typeof(c[3]) == Float64 || typeof(c[3]) == Int64
            if abs(c[3]) > 1e-18
                push!(connections_new_2, c)
            else
                # do not push! c[3] too small!
            end
        elseif isnull(tryparse(Float64,c[3]))
            # not a float and cannot be parsed to float, just push in list as it is
            push!(connections_new_2, c)
        else
            # check if the strength is non-zero
            if abs(parse(Float64,c[3])) > 1e-18
                push!(connections_new_2, c)
            else
                # do not push! c[3] too small!
            end
        end
    end
    # overwrite the connections in the given lattice
    lattice.connections = connections_new_2
end
function optimizeConnections!(unitcell::Unitcell)
    # build up new connections
    connections_new = Array[]
    # go through all old connections
    for c in unitcell.connections
        # check if the connection already is present in the list
        found = false
        for c_new in connections_new
            if c[1] == c_new[1] && c[2] == c_new[2] && c[4] == c_new[4]
                # found a redundent connection
                found = true
                # add connection strength
                if typeof(c[3]) == String || typeof(c_new[3]) == String
                    c_new[3] = "$(c_new[3])+$(c[3])"
                else
                    c_new[3] = c_new[3] + c[3]
                end
                # break the inner loop
                break
            end
        end
        # if not, add the current connection
        if !found
            push!(connections_new, c)
        end
    end
    # check if the connection strength is 0
    connections_new_2 = Array[]
    for c in connections_new
        # check if close to 0 connection strength
        if typeof(c[3]) == Float64 || typeof(c[3]) == Int64
            if abs(c[3]) > 1e-18
                push!(connections_new_2, c)
            else
                # do not push! c[3] too small!
            end
        elseif isnull(tryparse(Float64,c[3]))
            # not a float and cannot be parsed to float, just push in list as it is
            push!(connections_new_2, c)
        else
            # check if the strength is non-zero
            if abs(parse(Float64,c[3])) > 1e-18
                push!(connections_new_2, c)
            else
                # do not push! c[3] too small!
            end
        end
    end
    # overwrite the connections in the given lattice
    unitcell.connections = connections_new_2
end
export optimizeConnections!








#-----------------------------------------------------------------------------------------------------------------------------
#
#   Set / Map interaction strengths of the unitcell / lattice
#
#-----------------------------------------------------------------------------------------------------------------------------
function setAllInteractionStrengths!(unitcell::Unitcell, strengthNew)
    # go through all connections and modify their strength
    for c in unitcell.connections
        c[3] = strengthNew
    end
end
function setAllInteractionStrengths!(lattice::Lattice, strengthNew)
    # go through all connections and modify their strength
    for c in lattice.connections
        c[3] = strengthNew
    end
end
export setAllInteractionStrengths!



function mapInteractionStrengths!(unitcell::Unitcell, mapping; replace_in_strings=true, evaluate=false)
    # get the old strengths
    old_strengths = keys(mapping)
    # iterate for replacement
    for old_strength in old_strengths
        # new strength is given by mapping
        new_strength = mapping[old_strength]
        # check all connections that are identical
        for c in unitcell.connections
            if c[3] == old_strength
                c[3] = new_strength
            end
        end
        # check for string replacement
        if replace_in_strings
        for c in unitcell.connections
            if typeof(c[3]) == String && contains(c[3], old_strength)
                c[3] = replace(c[3], old_strength, new_strength)
            end
        end
        end
    end
    # maybe even evaluate
    if evaluate
        for c in unitcell.connections
            if typeof(c[3]) == String
                c[3] = eval(parse(c[3]))
            end
        end
    end
end
function mapInteractionStrengths!(lattice::Lattice, mapping; replace_in_strings=true, evaluate=false)
    # get the old strengths
    old_strengths = keys(mapping)
    # iterate for replacement
    for old_strength in old_strengths
        # new strength is given by mapping
        new_strength = mapping[old_strength]
        # check all connections that are identical
        for c in lattice.connections
            if c[3] == old_strength
                c[3] = new_strength
            end
        end
        # check for string replacement
        if replace_in_strings
        for c in lattice.connections
            if typeof(c[3]) == String && contains(c[3], old_strength)
                c[3] = replace(c[3], old_strength, new_strength)
            end
        end
        end
    end
    # maybe even evaluate
    if evaluate
        for c in lattice.connections
            if typeof(c[3]) == String
                c[3] = eval(parse(c[3]))
            end
        end
    end
end
export mapInteractionStrengths!






# TODO remove sites



#-----------------------------------------------------------------------------------------------------------------------------
#
#   Add interactions along next-nearest neighbors
#
#-----------------------------------------------------------------------------------------------------------------------------
function addNextNearestNeighborsToConnections!(lattice::Lattice; strengthNNN="AUTO", connectionsNN=["ALL"])
    # get the connectivity matrix of the lattice
    connectivity = getConnectionList(lattice)
    # define a list of new connections
    connections_new = Array[]
    # iterate over all sites and check if they host a NNN connection
    for i in 1:size(lattice.positions,1)
        # check the neighbors of site i
        for (i1,c1) in enumerate(connectivity[i])
        for (i2,c2) in enumerate(connectivity[i])
            # check if the connections are valid
            if !(in("ALL",connectionsNN) || (in(c1[3],connectionsNN) && in(c2[3],connectionsNN)))
                continue
            end
            # propose a connection c1+c2 if they are different
            if i1 < i2
                # build the offsets
                if length(c1[4]) == 1
                    off_1 = (c2[4] - c1[4])
                    off_2 = (c1[4] - c2[4])
                elseif length(c1[4]) == 2
                    off_1 = (c2[4][1] - c1[4][1], c2[4][2] - c1[4][2])
                    off_2 = (c1[4][1] - c2[4][1], c1[4][2] - c2[4][2])
                elseif length(c1[4]) == 3
                    off_1 = (c2[4][1] - c1[4][1], c2[4][2] - c1[4][2], c2[4][3] - c1[4][3])
                    off_2 = (c1[4][1] - c2[4][1], c1[4][2] - c2[4][2], c1[4][3] - c2[4][3])
                end
                # build two new connections
                if strengthNNN == "AUTO"
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); "NNN$(c1[2])to$(c2[2])"; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); "NNN$(c1[2])to$(c2[2])"; off_2]
                elseif strengthNNN == "MULTIPLY"
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); "$(c1[3])*$(c2[3])"; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); "$(c1[3])*$(c2[3])"; off_2]
                else
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); strengthNNN; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); strengthNNN; off_2]
                end
                # push them to the add list
                push!(connections_new, connection_new_1)
                push!(connections_new, connection_new_2)
            end
        end
        end
    end
    # push all connections to the lattice
    for c in connections_new
        push!(lattice.connections, c)
    end
end
function addNextNearestNeighborsToConnections!(unitcell::Unitcell; strengthNNN="AUTO", connectionsNN=["ALL"])
    # get the connectivity matrix of the unitcell
    connectivity = getConnectionList(unitcell)
    # define a list of new connections
    connections_new = Array[]
    # iterate over all sites and check if they host a NNN connection
    for i in 1:size(unitcell.basis,1)
        # check the neighbors of site i
        for (i1,c1) in enumerate(connectivity[i])
        for (i2,c2) in enumerate(connectivity[i])
            # check if the connections are valid
            if !(in("ALL",connectionsNN) || (in(c1[3],connectionsNN) && in(c2[3],connectionsNN)))
                continue
            end
            # propose a connection c1+c2 if they are different
            if i1 < i2
                # build the offsets
                if length(c1[4]) == 1
                    off_1 = (c2[4] - c1[4])
                    off_2 = (c1[4] - c2[4])
                elseif length(c1[4]) == 2
                    off_1 = (c2[4][1] - c1[4][1], c2[4][2] - c1[4][2])
                    off_2 = (c1[4][1] - c2[4][1], c1[4][2] - c2[4][2])
                elseif length(c1[4]) == 3
                    off_1 = (c2[4][1] - c1[4][1], c2[4][2] - c1[4][2], c2[4][3] - c1[4][3])
                    off_2 = (c1[4][1] - c2[4][1], c1[4][2] - c2[4][2], c1[4][3] - c2[4][3])
                end
                # build two new connections
                if strengthNNN == "AUTO"
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); "NNN$(c1[2])to$(c2[2])"; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); "NNN$(c1[2])to$(c2[2])"; off_2]
                elseif strengthNNN == "MULTIPLY"
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); "$(c1[3])*$(c2[3])"; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); "$(c1[3])*$(c2[3])"; off_2]
                else
                    connection_new_1 = [Int(c1[2]); Int(c2[2]); strengthNNN; off_1]
                    connection_new_2 = [Int(c2[2]); Int(c1[2]); strengthNNN; off_2]
                end
                # push them to the add list
                push!(connections_new, connection_new_1)
                push!(connections_new, connection_new_2)
            end
        end
        end
    end
    # push all connections to the unitcell
    for c in connections_new
        push!(unitcell.connections, c)
    end
end

export addNextNearestNeighborsToConnections!
