CC = mpicc
FC = mpif90
LD = mpif90
CFLAGS = -g -O3 -Wall -fopenmp
FFLAGS = -g -O3 -Wall -fopenmp -fimplicit-none
LDFLAGS = -g -O3 -Wall -fopenmp
LIBS = 

sord.x : sord.o \
        acceleration.o \
        dynamic_rupture.o \
        stress.o \
        time_integration.o \
        checkpoint.o \
        material_resample.o \
        kinematic_source.o \
        material_model.o \
        grid_generation.o \
        setup.o \
        statistics.o \
        parameters.o \
        field_io_mod.o \
        collective_mpi.o \
        fortran_io.o \
        arrays.o \
        utilities.o \
        surf_normals.o \
        boundary_cond.o \
        hourglass_op.o \
        diff_nc_op.o \
        diff_cn_op.o \
        kernels.o \
        globals.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

sord.o : sord.f90 \
        acceleration.mod \
        stress.mod \
        statistics.mod \
        dynamic_rupture.mod \
        parameters.mod \
        arrays.mod \
        collective.mod \
        material_model.mod \
        utilities.mod \
        checkpoint.mod \
        field_io_mod.mod \
        globals.mod \
        kinematic_source.mod \
        grid_generation.mod \
        time_integration.mod \
        setup.mod \
        material_resample.mod
	$(FC) $(FFLAGS) -c $<	

acceleration.o : acceleration.f90 \
        diff_cn_op.mod \
        statistics.mod \
        dynamic_rupture.mod \
        utilities.mod \
        field_io_mod.mod \
        globals.mod \
        hourglass_op.mod \
        boundary_cond.mod \
        kinematic_source.mod \
        collective.mod
	$(FC) $(FFLAGS) -c $<	

dynamic_rupture.o : dynamic_rupture.f90 \
        statistics.mod \
        collective.mod \
        utilities.mod \
        field_io_mod.mod \
        globals.mod \
        boundary_cond.mod \
        surf_normals.mod
	$(FC) $(FFLAGS) -c $<	

stress.o : stress.f90 \
        kernels.mod \
        statistics.mod \
        diff_nc_op.mod \
        utilities.mod \
        field_io_mod.mod \
        globals.mod \
        kinematic_source.mod
	$(FC) $(FFLAGS) -c $<	

time_integration.o : time_integration.f90 \
        statistics.mod \
        field_io_mod.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

checkpoint.o : checkpoint.f90 \
        statistics.mod \
        collective.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

material_resample.o : material_resample.f90 \
        boundary_cond.mod \
        collective.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

kinematic_source.o : kinematic_source.f90 \
        collective.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

material_model.o : material_model.f90 \
        collective.mod \
        globals.mod \
        utilities.mod \
        field_io_mod.mod
	$(FC) $(FFLAGS) -c $<	

grid_generation.o : grid_generation.f90 \
        collective.mod \
        diff_nc_op.mod \
        utilities.mod \
        field_io_mod.mod \
        globals.mod \
        boundary_cond.mod \
        surf_normals.mod
	$(FC) $(FFLAGS) -c $<	

setup.o : setup.f90 \
        collective.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

statistics.o : statistics.f90 \
        collective.mod \
        globals.mod \
        utilities.mod
	$(FC) $(FFLAGS) -c $<	

parameters.o : parameters.f90 \
        field_io_mod.mod \
        globals.mod
	$(FC) $(FFLAGS) -c $<	

field_io_mod.o : field_io_mod.f90 \
        collective.mod \
        globals.mod \
        utilities.mod \
        fortran_io.mod
	$(FC) $(FFLAGS) -c $<	

collective_mpi.o : collective_mpi.f90 \
        fortran_io.mod
	$(FC) $(FFLAGS) -c $<	

fortran_io.o : fortran_io.f90
	$(FC) $(FFLAGS) -c $<	

arrays.o : arrays.f90 \
        globals.mod
	$(FC) $(FFLAGS) -c $<	

utilities.o : utilities.f90
	$(FC) $(FFLAGS) -c $<	

surf_normals.o : surf_normals.f90
	$(FC) $(FFLAGS) -c $<	

boundary_cond.o : boundary_cond.f90
	$(FC) $(FFLAGS) -c $<	

hourglass_op.o : hourglass_op.f90
	$(FC) $(FFLAGS) -c $<	

diff_nc_op.o : diff_nc_op.f90
	$(FC) $(FFLAGS) -c $<	

diff_cn_op.o : diff_cn_op.f90
	$(FC) $(FFLAGS) -c $<	

kernels.o : kernels.f90
	$(FC) $(FFLAGS) -c $<	

globals.o : globals.f90
	$(FC) $(FFLAGS) -c $<

collective.mod : collective_mpi.o
	@true   

%.mod : %.o
	@true

clean :
	rm -f *.o *.mod *.x *.lst *.pyc

