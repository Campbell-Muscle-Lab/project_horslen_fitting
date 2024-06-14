function test_metrics

tfs = '../target_data/target_forces.txt';
sim_fs = '../progress/1/sim_prot_3_1_r1.txt';
ind = 3;

t = readtable(tfs)
sim = readtable(sim_fs)

t = t(:,ind);
nt = numel(t)

f = sim.m_force;
f = f(end-nt+1:end);
nf = numel(f)

r = (f - t)./(mean(t));

e = sum(r.^2)


