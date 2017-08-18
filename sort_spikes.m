
x=zeros(1,33);
for i=1:33
   %x=firingrate_by_location(i,:);
   %y=find(~isnan(x));
   x(i)=median(find(~isnan(firingrate_by_location(i,:))));
end
   [waste,index]=sort(x,'descend');

x=spike_bydistance_normalized(:,1);
imagesc(x,y, firingrate_by_location(index,:));
y=set(gca,'YLim',[1 33],'YTick',1:33,'YTickLabel',{index'});
colorbar;

