clear;
close all;

%% random number generator control
rng(20240705);
% disp(RandStream.getGlobalStream);

%% constants
position_a = [0; 0; 25]; % alice
position_b = [1; 0; 1.5]; % bob
center_frequency = 3.7e9;
update_rate = 0.01;
no_sc = 64; % subcarrier number
sc_bw = 20e6; % subcarrier bandwidth

%% a->b
%% antenna
a = qd_arrayant('dipole');
a.normalize_gain(1,35); % antenna gain
% a.visualize();
% a = qd_arrayant( 'parabolic', 3, center_frequency, [] , 3);       % Sat. antenna
% a.center_frequency = center_frequency;
% a.copy_element(1,2);                          	% Two identical elements
% a.rotate_pattern(90,'x',2);                   	% Rotate second element by 90 degrees
% a.combine_pattern;                           	% Merge polarized patterns
% a.rotate_pattern(-90,'y');                    	% Point skywards
% [directivity_dBi, gain_dBi] = a.calc_gain();

%% alice track
t_alice = qd_track('linear',0,0); % 不动
t_alice.initial_position = position_a;

%% bob track
t_bob = qd_track('linear', 0.75, 0); % 0.75m长
t_bob.movement_profile = [0, 0.5; 0, 0.75]; % 速度1.5m/s
t_bob.initial_position = position_b;

%% plot distance & time
% dist = t_bob.interpolate('time', 0.1);
% time = (0:numel(dist) - 2)* 0.1;
% plot(time,dist(1:100));
% xlabel('time/s');ylabel('dist/m');grid on;

%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器

l.tx_track = t_alice;
l.rx_track = t_bob;

l.set_scenario('3GPP_38.901_UMa_NLOS'); % 和论文一样

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

% l.visualize();title('a->b'); % 可视化

%% generate channel coeff & frequency response
c_initial = l.get_channels; % 计算信道系数
fr_initial = c_initial.fr(no_sc*sc_bw,no_sc); % frequency response : no_rx no_tx no_subcarrier no_snapshot
% disp("size of c_initial.coeff:")
% disp(size(c_initial.coeff));
% pow = 10*log10(reshape(sum(abs(c_initial.coeff(:,:,:,:)).^2,3),2,[]));

%% b->a
%% layout init
l = qd_layout;

l.simpar.center_frequency = center_frequency;
l.simpar.show_progress_bars = 0; % 禁用进度条指示器

l.tx_track = t_bob;
l.rx_track = t_alice;

l.set_scenario('3GPP_38.901_UMa_NLOS');

l.tx_array = a; % 在两端使用相同的天线
l.rx_array = a;

l.update_rate = update_rate;

% l.visualize();title('b->a');

%% generate channel coeff & frequency response
c_reversed = l.get_channels; % 计算新的信道系数
fr_reversed = c_reversed.fr(no_sc*sc_bw,no_sc);

%% plot multiple snapshots for comparison
snapshots_to_plot = [10, 20, 30, 40]; % 需要比较的时间快照
num_snapshots = length(snapshots_to_plot);

figure;
set(gcf,'Position',[100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 提取初始信道系数和反向信道系数
  h_initial = c_initial.coeff(:, :, :, snapshot); % no_rx no_tx no_path no_snapshot
  h_reversed = c_reversed.coeff(:, :, :, snapshot);
  % 创建子图
  subplot(2, 2, i);
  plot(real(h_initial(:)), imag(h_initial(:)), 'o', 'DisplayName', 'Initial(a->b)');
  hold on;
  plot(real(h_reversed(:)), imag(h_reversed(:)), 'x', 'DisplayName', 'Reversed(b->a)');
  title(['Ch Coeff(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end


figure;
set(gcf,'Position',[1100 100 1000 1000]);
for i = 1:num_snapshots
  snapshot = snapshots_to_plot(i);
  % 创建子图
  subplot(2, 2, i);
  plot(reshape(fr_initial(:,:,:,i),1,[]),'o','DisplayName', 'Initial(a->b)');
  hold on;
  plot(reshape(fr_reversed(:,:,:,i),1,[]),'x','DisplayName', 'Reversed(b->a)');
  title(['Ch Frequency Respose(Snapshot ', num2str(snapshot), ')'],'FontSize',15);
  xlabel('Re');
  ylabel('Im');
  legend('show','FontSize',10);
  hold off;
end
