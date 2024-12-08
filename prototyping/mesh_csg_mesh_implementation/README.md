
# Implementation of MCM (Mesh-to-CSG-to-Mesh)

This allows an acting physics body to "cut" a recieving physics body.

* both bodies must have a MeshInstance and some CollisionShape.
* One body, the acting body, will subtract its own shape from the recieving body upon contact.
* Cutting a mesh completely through will not create two objects, this requires extra logic to achieve.

This works as follows:
```
# New CSGMesh is created, and the recieving bodies mesh is set as the CSGMeshs Mesh
recieving_csg = CSGMesh.new()
recieving_csg.mesh = recieving_body.child_mesh_instance.mesh

# New CSGMesh is created, and the acting bodies mesh is set as the CSGMeshs Mesh
acting_csg = CSGMesh.new()
acting_csg.mesh = acting_body.child_mesh_instance.mesh

# For CSGs to interact, one must be a child of the other, the child will act on the parent
# So here we add the acting CSG as a child to the recieving CSG
recieving_csh.add_child(acting_csg)

# Positioning of the CSG nodes must be done here to ensure the operation happens
# at the desired location, otherwise it will happen at the origin

# Calling _update_shape() will cause the operation to run, updating the internal CSG mesh.
recieving_csg._update_shape()

# get_meshes() will return the internal CSG mesh resource after it has been updated.
new_mesh = recieving_csg.get_meshes()[1]

# Set the recieving bodies mesh to the new updated mesh.
recieving_body.child_mesh_instance.mesh = new_mesh
```

After the operation, the CSG nodes are removed, this removes the laggy nature 
of CSG objects at runtime, since CSG objects try to update the mesh of the receiving
object every single frame. In our implementation this allows for the same functionality
without carrying around CSGs or forcing the parent/child structure. 
