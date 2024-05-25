import countSlice from "./features/countSlice";
import userSlice from "./features/userSlice";
import orderSlice from "./features/orderSlice";
import  dataSlice  from "./features/dataSlice";
import dkLichRanhNsSlice from "./features/dkLichRanhNsSlice";
import { configureStore, combineReducers } from "@reduxjs/toolkit";
import {
  persistStore,
  persistReducer,
  FLUSH,
  REHYDRATE,
  PAUSE,
  PERSIST,
  PURGE,
  REGISTER,
} from "redux-persist";
import storage from "redux-persist/lib/storage";
const persistConfig = {
  key: "root",
  version: 1,
  storage,
  whitelist: ["count", "user", "stateData"],
};
const rootReducer = combineReducers({
  count: countSlice,
  user: userSlice,
  order: orderSlice,
  stateData: dataSlice,
  dangky: dkLichRanhNsSlice,
});

const persistedReducer = persistReducer(persistConfig, rootReducer);

const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
      },
    }),
});
export let persistor = persistStore(store);

export default store;
