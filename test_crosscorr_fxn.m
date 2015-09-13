clc

rxy=zeros(10000,1);
tic
for i=1:10000
    C=cov([x,y]);
    rxy(i)=C(1,2)/sqrt(C(1,1)*C(2,2));
end
toc

%%
rxy=zeros(10000,1);
tic
for i=1:10000
    rxy(i)=crosscorr(x,y);    
end
toc

%%
rxy=zeros(10000,1);
tic
for i=1:10000
    r=corrcoef(x,y);
    rxy(i)=r(1,2);
end
toc
%%
rxy=zeros(10000,1);
tic
for i=1:10000
    x_bar=mean(x);
    y_bar=mean(y);
    x_err=x-x_bar;
    y_err=y-y_bar;
    rxy(i)=sum(x_err.*y_err) / sqrt(sum(x_err.^2) * sum(y_err.^2));
end
toc
rxy(i)