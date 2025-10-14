import { LocalStorage } from "@raycast/api";
import { useState, useEffect, useCallback } from "react";

/**
 * Custom hook for reactive LocalStorage that automatically updates when values change
 * @param key The LocalStorage key
 * @param defaultValue Default value if key doesn't exist
 * @returns [value, setValue, isLoading] tuple
 */
export function useLocalStorage<T>(key: string, defaultValue: T): [T, (value: T) => Promise<void>, boolean] {
  const [value, setValue] = useState<T>(defaultValue);
  const [isLoading, setIsLoading] = useState(true);

  // Load initial value
  useEffect(() => {
    const loadValue = async () => {
      try {
        const stored = await LocalStorage.getItem<string>(key);
        if (stored !== null && stored !== undefined) {
          setValue(JSON.parse(stored));
        }
      } catch (error) {
        console.error(`Failed to load ${key} from LocalStorage:`, error);
      } finally {
        setIsLoading(false);
      }
    };

    loadValue();
  }, [key]);

  // Set value function that updates both state and LocalStorage
  const setStoredValue = useCallback(
    async (newValue: T) => {
      try {
        setValue(newValue);
        await LocalStorage.setItem(key, JSON.stringify(newValue));
      } catch (error) {
        console.error(`Failed to save ${key} to LocalStorage:`, error);
      }
    },
    [key],
  );

  return [value, setStoredValue, isLoading];
}

/**
 * Custom hook for managing arrays in LocalStorage with reactive updates
 * @param key The LocalStorage key
 * @param defaultValue Default array value
 * @returns [items, addItem, removeItem, clearItems, isLoading] tuple
 */
export function useLocalStorageArray<T>(
  key: string,
  defaultValue: T[] = [],
): [T[], (item: T) => Promise<void>, (predicate: (item: T) => boolean) => Promise<void>, () => Promise<void>, boolean] {
  const [items, setItems, isLoading] = useLocalStorage<T[]>(key, defaultValue);

  const addItem = useCallback(
    async (item: T) => {
      const newItems = [
        item,
        ...items.filter((existingItem) => JSON.stringify(existingItem) !== JSON.stringify(item)),
      ].slice(0, 20); // Keep last 20 items
      await setItems(newItems);
    },
    [items, setItems],
  );

  const removeItem = useCallback(
    async (predicate: (item: T) => boolean) => {
      const newItems = items.filter(predicate);
      await setItems(newItems);
    },
    [items, setItems],
  );

  const clearItems = useCallback(async () => {
    await setItems([]);
  }, [setItems]);

  return [items, addItem, removeItem, clearItems, isLoading];
}
