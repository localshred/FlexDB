package  
{
	import mx.collections.ArrayCollection;

	public class Table
	{
		private var _unique_key:String;
		
		private var indexes:Object = new Object;
		private var raw_collection:ArrayCollection;
		
		public var name:String;
		
		public var filterFunction:Function;
		
		public function Table()
		{
		}
		
		public function find(key:String):Object {
			if (unique_key && indexes.hasOwnProperty(unique_key) ) {
				
				if (indexes[unique_key].hasOwnProperty(key)) {
					return indexes[unique_key][key]
				}
				
			}
			
			return null;
		}
		
		public function find_all():ArrayCollection {
			var return_col:ArrayCollection = new ArrayCollection;
			
			if (raw_collection) {	
				return_col.source = return_col.source.concat(raw_collection.source);
			}
			
			return return_col;
		}
		
		public function find_all_by(index:String, value:String):ArrayCollection {
			var return_col:ArrayCollection = new ArrayCollection;
			if (indexes[index].hasOwnProperty(value) && indexes[index][value] && indexes[index][value] is Array) {
				return_col.source = return_col.source.concat(indexes[index][value]);
			}

			return  return_col;
		}
		
		public function find_between(index:String, start:Object, end:Object):ArrayCollection {
			var col:ArrayCollection = new ArrayCollection();
			
			for each (var key:Object in indexes[index]) {			
				if (key >= start || key <= end) {
					col.addAll(indexes[index][key])
				} 		
			}
			
			return col
		}
		
		public function find_all_by_filter():ArrayCollection {
			var filtered_collection:ArrayCollection = new ArrayCollection(raw_collection.source.slice(0,raw_collection.length));
			filtered_collection.filterFunction = filterFunction;
			filtered_collection.refresh();
			return filtered_collection;
		}
		
		
		public function insert(collection:ArrayCollection):ArrayCollection {
			var inserted:ArrayCollection = new ArrayCollection;
			
			for each (var item:Object in collection) {
				if (unique_key && indexes.hasOwnProperty(unique_key) ) {
					
					if (indexes[unique_key].hasOwnProperty(item[unique_key])) {
						continue
					}
	
				}
				
				for (var index:String in indexes) {
					indexItem(item, index);
				}
				
				if (!raw_collection) {
					raw_collection = new ArrayCollection;
				}
				raw_collection.addItem(item);
				inserted.addItem(item);
			}
			return inserted
		}
		
		public function update(item:Object):void {
			if (unique_key && indexes.hasOwnProperty(unique_key) ) {
				
				if (indexes[unique_key].hasOwnProperty(item[unique_key])) {
					remove(item);	
				}
				
				insert(new ArrayCollection([item]));
			}
		}
		
		public function remove(item:Object):void {
			if (raw_collection.contains(item)) {
				for (var index:String in indexes) {
					unindexItem(item, index);
				}
				
				raw_collection.removeItemAt(raw_collection.getItemIndex(item));
			}
		}
		
		
		public function set unique_key(key:String):void {
			_unique_key = key;
			addIndexes([key]);
		}
		
		public function get unique_key():String {
			return _unique_key;
		}
		
		public function addIndexes(array:Array):void {
			
			for each(var index:String in array) {
				if (indexes.hasOwnProperty(name)) {
					continue;
				} else {
					indexes[index] = new Object;
					indexCollection(index);
				}
			}
		}
		
		
		private function indexCollection(index:String):void {
			for each(var item:Object in  raw_collection) {
				indexItem(item, index);
			}
		}
		
		private function indexItem(item:Object, index:String):void {
			if (item.hasOwnProperty(index) || (index.indexOf('.') > -1)) {
				if (index == unique_key) {
					indexes[index][item[index]] = item;
				} else {
					if (index.indexOf('.') > -1) {
						//complex index
						var pieces:Array = index.split('.');
						var arrayKey:String = pieces[0];
						var arrayVal:String = pieces[1];
						
						for each(var subItem:Object in item[arrayKey]) {
							if (!indexes[index].hasOwnProperty(subItem[arrayVal].toString())) {
								indexes[index][subItem[arrayVal].toString()] = new Array;
							}
							
														
							(indexes[index][subItem[arrayVal].toString()] as Array).push(item);
						}
						
						
					} else {
					
						if (!indexes[index].hasOwnProperty(item[index].toString())) {
							indexes[index][item[index].toString()] = new Array;
						}
						
						(indexes[index][item[index].toString()] as Array).push(item);
					}
				}
				
				
			}
		}
		
		private function unindexItem(item:Object, index:String):void {
			if (index == unique_key) {
				delete indexes[index][item[index]]
			} else {
				var itemIndex:Number
				
				if (index.indexOf('.') > -1) {
					
					var pieces:Array = index.split('.');
					var arrayKey:String = pieces[0];
					var arrayVal:String = pieces[1];
					
					for each(var subItem:Object in item[arrayKey]) {
						itemIndex = (indexes[index][subItem[arrayVal].toString()] as Array).indexOf(item)
						
						if (itemIndex > -1) {
							(indexes[index][subItem[arrayVal].toString()] as Array).splice(itemIndex, 1);
						}

					}
					
				} else {
					itemIndex = (indexes[index][item[index].toString()] as Array).indexOf(item)
							
					if (itemIndex > -1) {
						(indexes[index][item[index].toString()] as Array).splice(itemIndex, 1);
					}
				}
			}
			
		}
		
		
		
	}
}