% 绘制两离散曲线的交点
% 注意：
%   1. 这里的“交点”指的是离散点连线绘出的图形的交点，而非函数或者方程理论分析上的交点，
%      因此，这个程序不能作为求根来用。
%   2. 要求两曲线的离散点的个数一样。
%   3. 两个曲线出现参数方程的话，大多数情况正常。但是经测试发现，对于某些非常特殊的情况会出现bug,
%      除非调用ezplot的数据（xdata,ydata）。
%
%   by kastin @Mar 21, 2012
clear;
debug=true; %关闭显示求交点过程
% 曲线1
x=0:pi/18:2*pi;
y=cos(2*x).*exp(sin(x));

% 曲线2
[x1 N]=sort(x);  %此处对于C1参数方程，C2为显式函数；或者均为参数方程时候有用
% 下面几句代码在本个案下没有什么特殊作用，但是当出现参数方程的时候，下面的方法改动一下就会有用。
y1=sin(x1).^2+cos(x1); %用于作图
x2=x;
y2=sin(x).^2+cos(x); %用于寻点


h=plot(x1,y1,'b',x,y,'c');
y(abs(y)<=eps)=0; y2(abs(y2)<=eps)=0;%对于三角函数关于零点的部分处理,但是发现sin(k*pi)不一定全在eps范围内
cy=y2-y; %作差
line(x1,cy);
%符号记录
pos=cy>0;
neg=cy<=0;
%确定变号位置
fro=diff(pos)~=0; %变号的前导位置
rel=diff(neg)~=0; %变号的尾巴位置
zpf=find(fro==1); %记录索引
zpr=find(rel==1)+1; %记录索引
zpfr=[zpf; zpr];
hold on
% 观看求交点过程
if debug, hp=plot(x(zpfr),y(zpfr),'r.-',x2(zpfr),y2(zpfr),'g.-'); end
%线性求交
x0=(x(zpr).*(y2(zpf)-y(zpf)) -x(zpf).*(y2(zpr)-y(zpr)))  ./(y(zpr)+y2(zpf)  -y(zpf)-y2(zpr));
y0=y(zpf)+(x0-x(zpf)).*(y(zpr)-y(zpf))./(x(zpr)-x(zpf));
if any(isnan(y0)), y0=y2(zpf); end
%加入已经判断为零的位置
%可能有的同学会说两个曲线都弄出来0点了还判断条毛？因为曲线不是完全连续的，本题说得是离散情况下的
%要求得两个离散点之间的点需要线性求交
x0=[x(abs(cy)<=eps) x0].';
y0=[y(abs(cy)<=eps) y0].';
hc=plot(x0,y0,'k.'); %绘制交点
if debug, legend([h;hc;hp(1);hp(end)],'C1','C2','交点','微线段1','微线段2',0); end
legend([h;hc],'C1','C2','交点',0)
xlabel('x'), ylabel('y'), zlabel('z');
title('平面曲线交点')
axis equal
hold off
disp('交点坐标[x,y]为：')
disp(unique([x0,y0],'rows')) %排除重复的点